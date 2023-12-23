using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace WozDev
{
    public class IniParser
    {

/// <summary>
/// Parses a string containing INI file contents and converts it into an IniObject.
/// </summary>
/// <param name="iniString">A string containing the contents of an INI file.</param>
/// <returns>An IniObject representing the parsed INI data.</returns>
public static IniObject Parse(string iniString)
{
    // Initialize a variable to keep track of the current section
    string section = string.Empty;

    // Create an IniObject to store the parsed data
    IniObject result = new IniObject();

    // Use StringReader to read the iniString line by line
    using (StringReader reader = new StringReader(iniString))
    {
        // Regex pattern to identify sections in the INI file
        Regex iniSectionRgx = new Regex(@"^\[(.+)\]$");

        // Regex pattern to identify key-value pairs in the INI file
        Regex iniEntryRgx = new Regex(@"^\s*([^#].+?)\s*=\s*(.*)");

        string line;

        // Read each line from the iniString
        while ((line = reader.ReadLine()) != null)
        {
            // Match the current line against the section regex pattern
            var sectionMatch = iniSectionRgx.Match(line);

            // Match the current line against the key-value pair regex pattern
            var entryMatch = iniEntryRgx.Match(line);

            // If the line is a section header
            if (sectionMatch.Success)
            {
                // Update the current section variable with the section name
                section = sectionMatch.Groups[1].Value.Trim();
            }
            // If the line is a key-value pair
            else if (entryMatch.Success)
            {
                // Extract the key and value from the matched groups
                string iniEntryKey = entryMatch.Groups[1].Value.Trim();
                string iniEntryValue = entryMatch.Groups[2].Value.Trim();

                // Add the key-value pair to the IniObject under the current section
                result.Add(section, iniEntryKey, iniEntryValue);
            }
        }
    }

    // Return the populated IniObject
    return result;
}

        /// <summary>
        /// Parses an INI file and converts it into an IniObject.
        /// </summary>
        /// <param name="filePath">Path to the INI file.</param>
        /// <returns>An IniObject representing the INI file.</returns>
        public static IniObject ParseFile(string filePath)
        {
            // Read the contents of the file into a string
            string iniString = File.ReadAllText(filePath);

            // Call the Parse method with the contents of the file
            return Parse(iniString);
        }

        /// <summary>
        /// Parses an INI file with specified encoding and converts it into an IniObject.
        /// </summary>
        /// <param name="filePath">Path to the INI file.</param>
        /// <param name="encoding">The encoding used to read the file.</param>
        /// <returns>An IniObject representing the INI file.</returns>
        public static IniObject ParseFile(string filePath, Encoding encoding)
        {
            // Read the contents of the file into a string with the specified encoding
            string iniString = File.ReadAllText(filePath, encoding);

            // Call the Parse method with the contents of the file
            return Parse(iniString);
        }
    }
}
