using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Jayse.UnitTests
{
    [TestClass]
    public class ParsingTests
    {

        [TestMethod]
        public void Go()
        {
            var text = File.ReadAllText("book.json");
            var parser = new JsonParser(text);
            var asdsad = parser.Parse();
            Assert.IsNotNull(asdsad);
        }
    }
}

