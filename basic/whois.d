import std.algorithm.searching : startsWith;
import std.array : appender;
import std.socket;
import std.stdio : stderr, write, writeln;
import std.string : indexOf, lineSplitter, strip, toLower;

enum ushort WHOIS_PORT = 43;
enum size_t BUFFER_SIZE = 4096;

void usage(string program)
{
    writeln("OffensiveD WHOIS Client");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " <domain-or-IP> [WHOIS-server]");
    writeln();
    writeln("Examples:");
    writeln("  ", program, " example.com");
    writeln("  ", program, " example.com whois.verisign-grs.com");
}

string queryWhois(string server, string query)
{
    Address[] addresses = getAddress(server, WHOIS_PORT);

    if (addresses.length == 0)
        throw new Exception("Could not resolve WHOIS server: " ~ server);

    auto socket = new TcpSocket();
    scope (exit)
        socket.close();

    socket.connect(addresses[0]);

    immutable string request = query ~ "\r\n";
    size_t totalSent;

    while (totalSent < request.length)
    {
        immutable sent = socket.send(request[totalSent .. $]);

        if (sent == Socket.ERROR)
            throw new Exception("Failed to send WHOIS request");

        if (sent == 0)
            throw new Exception("WHOIS connection closed while sending");

        totalSent += sent;
    }

    auto response = appender!string();
    ubyte[BUFFER_SIZE] buffer;

    while (true)
    {
        immutable received = socket.receive(buffer[]);

        if (received == Socket.ERROR)
            throw new Exception("Failed to receive WHOIS response");

        if (received == 0)
            break;

        response.put(cast(string) buffer[0 .. received]);
    }

    return response.data;
}

string findReferral(string response)
{
    foreach (line; response.lineSplitter)
    {
        immutable cleaned = line.strip();
        immutable lowered = cleaned.toLower();

        foreach (prefix; ["refer:", "whois:", "referralserver:"])
        {
            if (!lowered.startsWith(prefix))
                continue;

            string server = cleaned[prefix.length .. $].strip();

            if (server.startsWith("whois://"))
                server = server["whois://".length .. $];

            immutable slash = server.indexOf('/');

            if (slash >= 0)
                server = server[0 .. slash];

            immutable colon = server.indexOf(':');

            if (colon >= 0)
                server = server[0 .. colon];

            return server.strip();
        }
    }

    return null;
}

void main(string[] args)
{
    if (args.length < 2 || args.length > 3)
    {
        usage(args[0]);
        return;
    }

    immutable string target = args[1];
    immutable bool customServer = args.length == 3;

    string server = customServer
        ? args[2]
        : "whois.iana.org";

    try
    {
        writeln("[*] Querying ", server, " for ", target, "...");
        writeln();

        string response = queryWhois(server, target);

        if (!customServer)
        {
            immutable referral = findReferral(response);

            if (referral.length > 0 && referral != server)
            {
                writeln("[*] Referral found: ", referral);
                writeln("[*] Following referral...");
                writeln();

                server = referral;
                response = queryWhois(server, target);
            }
        }

        writeln("WHOIS server: ", server);
        writeln("----------------------------------------");
        write(response);

        if (response.length == 0 || response[$ - 1] != '\n')
            writeln();

        writeln("----------------------------------------");
    }
    catch (SocketOSException error)
    {
        stderr.writeln("[-] Socket error: ", error.msg);
    }
    catch (Exception error)
    {
        stderr.writeln("[-] WHOIS query failed: ", error.msg);
    }
}