import std.algorithm;
import std.file;
import std.net.curl;
import std.stdio;
import std.string;

void usage(string prog)
{
    writeln("Directory Bruteforcer");
    writeln();
    writeln("Usage:");
    writeln("  ", prog, " <url> <wordlist>");
}

void main(string[] args)
{
    if (args.length != 3)
    {
        usage(args[0]);
        return;
    }

    string base = args[1];
    string wordlist = args[2];

    if (!base.endsWith("/"))
        base ~= "/";

    foreach (line; readText(wordlist).splitLines())
    {
        string path = line.strip();

        if (path.length == 0)
            continue;

        string url = base ~ path;

        auto http = HTTP(url);

        http.method = HTTP.Method.get;

        http.addRequestHeader(
            "User-Agent",
            "DBuster"
        );

        try
        {
            http.perform();

            writeln(
                "[",
                http.statusLine.code,
                "] ",
                url
            );
        }
        catch (CurlException)
        {
            // Ignore
        }
    }
}