import std.socket;
import std.stdio;
import std.conv;

void main(string[] args)
{
    if (args.length != 2)
    {
        writeln("Usage: scanner <host>");
        return;
    }

    string host = args[1];

    foreach (port; 20 .. 1025)
    {
        auto sock = new TcpSocket();

        try
        {
            sock.connect(new InternetAddress(host, cast(ushort)port));
            writeln("[+] Open: ", port);
        }
        catch (Exception)
        {
            // Port closed or filtered
        }

        sock.close();
    }
}