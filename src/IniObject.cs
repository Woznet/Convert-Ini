using System.Collections.Generic;

namespace WozDev
{
    public class IniObject
    {
        // Dictionary to hold sections and their key-value pairs
        public Dictionary<string, Dictionary<string, string>> Sections { get; set; }

        public IniObject()
        {
            Sections = new Dictionary<string, Dictionary<string, string>>();
        }

        // Method to add a key-value pair to a section
        public void Add(string section, string key, string value)
        {
            if (!Sections.ContainsKey(section))
            {
                Sections[section] = new Dictionary<string, string>();
            }

            Sections[section][key] = value;
        }

        // Method to get a section by name (optional, for convenience)
        public Dictionary<string, string> GetSection(string sectionName)
        {
            return Sections.ContainsKey(sectionName) ? Sections[sectionName] : null;
        }
    }
}
