import std.digest : toHexString;
import std.digest.md : md5Of;
import std.digest.sha :
    sha1Of,
    sha256Of,
    sha384Of,
    sha512Of;
import std.stdio : stderr, writeln;
import std.string : representation, toLower;

void usage(string program)
{
    writeln("OffensiveD Hash Generator");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " <algorithm> <text>");
    writeln();
    writeln("Algorithms:");
    writeln("  md5");
    writeln("  sha1");
    writeln("  sha256");
    writeln("  sha384");
    writeln("  sha512");
    writeln();
    writeln("Examples:");
    writeln(`  `, program, ` sha256 "OffensiveD"`);
    writeln(`  `, program, ` md5 "password"`);
}

void main(string[] args)
{
    if (args.length != 3)
    {
        usage(args[0]);
        return;
    }

    immutable string algorithm = args[1].toLower();
    immutable string input = args[2];

    switch (algorithm)
    {
        case "md5":
            writeln(toHexString(md5Of(input.representation)));
            break;

        case "sha1":
            writeln(toHexString(sha1Of(input.representation)));
            break;

        case "sha256":
            writeln(toHexString(sha256Of(input.representation)));
            break;

        case "sha384":
            writeln(toHexString(sha384Of(input.representation)));
            break;

        case "sha512":
            writeln(toHexString(sha512Of(input.representation)));
            break;

        default:
            stderr.writeln("[-] Unsupported algorithm: ", args[1]);
            writeln();
            usage(args[0]);
            break;
    }
}