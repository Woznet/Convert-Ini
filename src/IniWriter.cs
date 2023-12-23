using System;
using System.Text;

namespace WozDev
{
    public class IniWriter
    {
        /// <summary>
        /// Convert IniObject to ini string.
        /// </summary>
        /// <param name="inputObject">The IniObject to convert.</param>
        /// <param name="compressed">Determines if the output should be compressed (no extra line breaks).</param>
        /// <returns>A string in INI format.</returns>
        public static string Write(IniObject inputObject, bool compressed = false)
        {
            StringBuilder output = new StringBuilder();
            string newLine = compressed ? string.Empty : Environment.NewLine;

            foreach (var section in inputObject.Sections)
            {
                if (!compressed)
                {
                    // Add a new line before each section, except for the first
                    if (output.Length > 0)
                    {
                        output.Append(newLine);
                    }
                }

                // Append the section header
                output.Append($"[{section.Key}]{newLine}");

                // Append each key-value pair within the section
                foreach (var keyValue in section.Value)
                {
                    output.Append($"{keyValue.Key}={keyValue.Value}{newLine}");
                }
            }

            return output.ToString();
        }
    }
}
