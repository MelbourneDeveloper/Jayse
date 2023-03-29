using System.IO;
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
            var jsonValue = parser.Parse();
            Assert.IsNotNull(jsonValue);
            var actual = jsonValue["books"].ArrayValue[0]["title"].StringValue;
            Assert.AreEqual("The Catcher in the Rye", actual);
        }
    }
}

