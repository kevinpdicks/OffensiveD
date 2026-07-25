import std.net.curl : CurlException, HTTP;
import std.stdio : stderr, stdout, writeln;

void usage(string program)
{
    writeln("OffensiveD HTTP GET Client");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " <URL>");
    writeln();
    writeln("Examples:");
    writeln("  ", program, " http://example.com/");
    writeln("  ", program, " https://example.com/");
}

void main(string[] args)
{
    if (args.length != 2)
    {
        usage(args[0]);
        return;
    }

    immutable url = args[1];

    try
    {
        auto client = HTTP(url);

        client.method = HTTP.Method.get;
        client.maxRedirects = 5;
        client.addRequestHeader(
            "User-Agent",
            "OffensiveD-HTTP-Client/1.0"
        );
        client.addRequestHeader(
            "Accept",
            "*/*"
        );
        client.addRequestHeader(
            "Connection",
            "close"
        );

        client.onReceiveStatusLine = (status)
        {
            writeln(
                "< HTTP/",
                status.majorVersion,
                ".",
                status.minorVersion,
                " ",
                status.code,
                " ",
                status.reason
            );
        };

        client.onReceiveHeader = (in char[] name, in char[] value)
        {
            /*
             * The callback may provide an empty name for separator
             * or status-related lines, so handle it cleanly.
             */
            if (name.length > 0)
                writeln("< ", name, ": ", value);
        };

        client.onReceive = (ubyte[] data)
        {
            stdout.rawWrite(data);
            return data.length;
        };

        writeln("[*] GET ", url);
        writeln();

        client.perform();
    }
    catch (CurlException error)
    {
        stderr.writeln("[-] HTTP request failed: ", error.msg);
    }
    catch (Exception error)
    {
        stderr.writeln("[-] Error: ", error.msg);
    }
}