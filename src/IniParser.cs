using System.IO;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace ConvertIni
{
    public class IniParser
    {
        private static readonly Regex IniSectionRegex = new Regex(@"^\[(.+)\]$", RegexOptions.Compiled);
        private static readonly Regex IniEntryRegex = new Regex(@"^\s*([^#;].+?)\s*=\s*(.*)", RegexOptions.Compiled);

        public static object Parse(string iniString)
        {
            return ParseIni(new StringReader(iniString));
        }

        public static object ParseFile(string iniFilePath)
        {
            return ParseIni(new StreamReader(iniFilePath));
        }

        public static object ParseFile(string iniFilePath, System.Text.Encoding encoding)
        {
            return ParseIni(new StreamReader(iniFilePath, encoding));
        }

        private static object ParseIni(TextReader reader)
        {
            string section = string.Empty;
            PSObject result = new PSObject();

            string line;
            while ((line = reader.ReadLine()) != null)
            {
                var sectionMatch = IniSectionRegex.Match(line);
                var entryMatch = IniEntryRegex.Match(line);

                if (sectionMatch.Success)
                {
                    section = sectionMatch.Groups[1].Value.Trim();
                }
                else if (entryMatch.Success)
                {
                    string iniEntryKey = entryMatch.Groups[1].Value.Trim();
                    string iniEntryValue = entryMatch.Groups[2].Value.Trim();
                    if (iniEntryValue.StartsWith("\"") && iniEntryValue.EndsWith("\"") && iniEntryValue.Length > 1)
                    {
                        iniEntryValue = iniEntryValue.Substring(1, iniEntryValue.Length - 2);
                    }

                    if (string.IsNullOrEmpty(section))
                    {
                        result.Properties.Add(new PSNoteProperty(iniEntryKey, iniEntryValue));
                    }
                    else
                    {
                        if (result.Properties[section] == null)
                        {
                            result.Properties.Add(new PSNoteProperty(section, new PSObject()));
                        }
                        ((PSObject)result.Properties[section].Value).Properties.Add(new PSNoteProperty(iniEntryKey, iniEntryValue));
                    }
                }
            }

            return result;
        }
    }
}
