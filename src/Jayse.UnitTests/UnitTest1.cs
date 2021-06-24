using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;
using System.Linq;

namespace Jayse.UnitTests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestTheJsons()
        {
            var originalJson = File.ReadAllText("TestData.json");
            var jsonObject = originalJson.ToJsonObject();
            Assert.IsNotNull(jsonObject);

            Assert.AreEqual(5, jsonObject.Count);

            var features = jsonObject["features"];

            var properties = features.
                ArrayValue[0].
                ObjectValue["properties"];


            var geometry = features.
                            ArrayValue.First().
                            ObjectValue["geometry"];

            var coordinatesObject = geometry.ObjectValue["coordinates"];

            var coordinatesArray = coordinatesObject.ArrayValue;

            Assert.AreEqual(JsonValueType.OfNull, jsonObject["stuff"].ValueType);

            Assert.AreEqual(new Guid("72cdd9ee-b48d-41af-b6b4-63df02eb7e18"),
            jsonObject["features"][0]["properties"]["ID"].AsGuid());

            Assert.AreEqual("name",
                jsonObject["crs"]
                ["type"].
                StringValue);

            Assert.AreEqual(1,
                properties.
                ObjectValue["OBJECTID"].
                NumberValue);

            Assert.AreEqual(true,
                properties.
                ObjectValue["ISBIG"].
                BooleanValue);

            Assert.AreEqual("72cdd9ee-b48d-41af-b6b4-63df02eb7e18",
                properties.
                ObjectValue["ID"].
                StringValue);

            Assert.AreEqual("2009-02-15T00:00:00.000Z",
                properties.
                ObjectValue["INSTALLDATE"].
                StringValue);

            Assert.AreEqual((decimal)145.070165949298001,
                coordinatesArray.First().NumberValue);

            Console.WriteLine(jsonObject.ToJson(false));
            Console.WriteLine();
            Console.WriteLine(jsonObject.ToJson(true));
        }
    }
}




