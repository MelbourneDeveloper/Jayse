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
            var jsonValue = new JsonParser(text).Parse();
            Assert.IsNotNull(jsonValue);
            Assert.AreEqual("The Catcher in the Rye", jsonValue["books"].ArrayValue[0]["title"].StringValue);
            Assert.AreEqual(1951, jsonValue["books"].ArrayValue[0]["publication"]["year"].NumberValue);
        }
    }
}

