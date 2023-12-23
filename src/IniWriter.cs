using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text;

namespace ConvertIni
{
    public class IniWriter
    {
        /// <summary>
        /// Convert PSObject to ini string.
        /// </summary>
        /// <param name="inputObject">The PSObject to convert.</param>
        /// <param name="compressed">Determines if the output should be compressed (no extra line breaks).</param>
        /// <returns>A string in INI format.</returns>
        public static string Write(PSObject inputObject, bool compressed = false)
        {
            StringBuilder output = new StringBuilder();
            List<string> noSection = compressed ? null : new List<string>();
            string newLine = compressed ? string.Empty : Environment.NewLine;

            foreach (PSNoteProperty item in inputObject.Properties)
            {
                string itemValue = item.Value?.ToString() ?? string.Empty;

                if (item.Value is PSObject childObject)
                {
                    output.AppendLine($"[{item.Name}]");
                    output.Append(Write(childObject, compressed));
                }
                else
                {
                    noSection?.Add($"{item.Name}={itemValue}");
                }
            }

            if (!compressed)
            {
                output.Insert(0, $"{string.Join(Environment.NewLine, noSection)}{newLine}");
            }

            return output.ToString();
        }
    }
}
