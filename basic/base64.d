import std.base64 :
    Base64,
    Base64URL,
    Base64URLNoPadding;
import std.stdio : stderr, write, writeln;
import std.string : representation, toLower;

void usage(string program)
{
    writeln("OffensiveD Base64 Utility");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " encode <text>");
    writeln("  ", program, " decode <Base64>");
    writeln("  ", program, " url-encode <text>");
    writeln("  ", program, " url-decode <Base64URL>");
    writeln("  ", program, " jwt-encode <text>");
    writeln("  ", program, " jwt-decode <Base64URL>");
    writeln();
    writeln("Examples:");
    writeln(`  `, program, ` encode "OffensiveD"`);
    writeln(`  `, program, ` decode "T2ZmZW5zaXZlRA=="`);
    writeln(`  `, program, ` jwt-decode "eyJhbGciOiJIUzI1NiJ9"`);
}

void printDecoded(const(ubyte)[] decoded)
{
    write(cast(const(char)[]) decoded);

    if (decoded.length == 0 || decoded[$ - 1] != '\n')
        writeln();
}

void main(string[] args)
{
    if (args.length != 3)
    {
        usage(args[0]);
        return;
    }

    immutable string operation = args[1].toLower();
    immutable string input = args[2];

    try
    {
        switch (operation)
        {
            case "encode":
                writeln(Base64.encode(input.representation));
                break;

            case "decode":
                printDecoded(Base64.decode(input));
                break;

            case "url-encode":
                writeln(Base64URL.encode(input.representation));
                break;

            case "url-decode":
                printDecoded(Base64URL.decode(input));
                break;

            case "jwt-encode":
                writeln(
                    Base64URLNoPadding.encode(input.representation)
                );
                break;

            case "jwt-decode":
                printDecoded(Base64URLNoPadding.decode(input));
                break;

            default:
                stderr.writeln("[-] Unknown operation: ", args[1]);
                writeln();
                usage(args[0]);
                break;
        }
    }
    catch (Exception error)
    {
        stderr.writeln("[-] Base64 operation failed: ", error.msg);
    }
}