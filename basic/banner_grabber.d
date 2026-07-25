import std.conv : to;
import std.datetime : dur;
import std.socket;
import std.stdio : stderr, write, writeln;

enum BUFFER_SIZE = 4096;

void usage(string program)
{
    writeln("OffensiveD Banner Grabber");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " <host> <port> [probe]");
    writeln();
    writeln("Examples:");
    writeln("  ", program, " 192.168.0.1 22");
    writeln(
        "  ",
        program,
        ` example.com 80 "HEAD / HTTP/1.0\r\nHost: example.com\r\n\r\n"`
    );
}

void main(string[] args)
{
    if (args.length < 3 || args.length > 4)
    {
        usage(args[0]);
        return;
    }

    immutable string host = args[1];

    ushort port;

    try
    {
        port = to!ushort(args[2]);
    }
    catch (Exception)
    {
        stderr.writeln("[-] Invalid port: ", args[2]);
        return;
    }

    try
    {
        Address[] addresses = getAddress(host, port);

        if (addresses.length == 0)
        {
            stderr.writeln("[-] Could not resolve host: ", host);
            return;
        }

        auto socket = new TcpSocket();
        scope (exit)
            socket.close();

        socket.setOption(
            SocketOptionLevel.SOCKET,
            SocketOption.RCVTIMEO,
            dur!"seconds"(5)
        );

        socket.setOption(
            SocketOptionLevel.SOCKET,
            SocketOption.SNDTIMEO,
            dur!"seconds"(5)
        );

        writeln("[*] Connecting to ", host, ":", port, "...");

        /*
         * getAddress() returns Address[], so select the first
         * resolved address.
         */
        socket.connect(addresses[0]);

        writeln("[+] Connected");

        if (args.length == 4)
        {
            immutable string probe = decodeEscapes(args[3]);

            writeln("[*] Sending probe...");

            immutable sent = socket.send(probe);

            if (sent == Socket.ERROR)
            {
                stderr.writeln("[-] Failed to send probe");
                return;
            }
        }

        ubyte[BUFFER_SIZE] buffer;
        immutable received = socket.receive(buffer[]);

        if (received == Socket.ERROR)
        {
            stderr.writeln(
                "[-] Failed to receive banner: ",
                socket.getErrorText()
            );
            return;
        }

        if (received == 0)
        {
            writeln("[-] Connection closed without returning a banner");
            return;
        }

        writeln("[+] Received ", received, " bytes:");
        writeln("----------------------------------------");

        write(cast(string) buffer[0 .. received]);

        if (buffer[received - 1] != '\n')
            writeln();

        writeln("----------------------------------------");
    }
    catch (SocketOSException error)
    {
        stderr.writeln("[-] Socket error: ", error.msg);
    }
    catch (Exception error)
    {
        stderr.writeln("[-] Error: ", error.msg);
    }
}

string decodeEscapes(string input)
{
    string output;

    for (size_t i = 0; i < input.length; ++i)
    {
        if (input[i] != '\\' || i + 1 >= input.length)
        {
            output ~= input[i];
            continue;
        }

        switch (input[++i])
        {
            case 'r':
                output ~= '\r';
                break;

            case 'n':
                output ~= '\n';
                break;

            case 't':
                output ~= '\t';
                break;

            case '\\':
                output ~= '\\';
                break;

            default:
                output ~= '\\';
                output ~= input[i];
                break;
        }
    }

    return output;
}