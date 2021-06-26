using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;

namespace Jayse.UnitTests
{


    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestToJsonValue()
        {
            const string stringValue = "stringValue";
            var jsonValue = stringValue.ToJsonValue();
            Assert.AreEqual(stringValue, jsonValue.StringValue);
        }

        [TestMethod]
        public void TestToJsonValue2()
        {
            var jsonValue = true.ToJsonValue();
            Assert.AreEqual(true, jsonValue.BooleanValue);
        }

        [TestMethod]
        public void TestCreateJsonObject()
        {
            const string key = "key";
            var jsonValue = new JsonValue("value");
            var dictionary = jsonValue.CreateJsonObject(key);
            Assert.AreEqual(jsonValue, dictionary[key]);
        }

        [TestMethod]
        public void TestCreateJsonObject2()
        {
            const string key = "key";
            var jsonValue = "value".ToJsonValue();

            var dictionary =
                new List<KeyValuePair<string, JsonValue>>
                {
                    new(key, jsonValue),
                    new("key2", "value2".ToJsonValue())
                }
                .CreateJsonObject();

            Assert.AreEqual(jsonValue, dictionary[key]);
        }

        [TestMethod]
        public void TestBuilder()
        {
            const string key3 = "key3";
            const string value3 = "value3";
            const string value1 = "value1";
            const string key1 = "key1";

            var dictionary =
                value1.
                ToBuilder(key1).
                Add("key2", "value2").
                Add(key3, value3).
                Build();

            Assert.AreEqual(value1, dictionary[key1].StringValue);
            Assert.AreEqual(value3, dictionary[key3].StringValue);
        }

        [TestMethod]
        public void TestNonDestructiveMutability()
        {
            var expectedJson = File.ReadAllText("TestDataMutated.json");
            var jsonObject = File.ReadAllText("TestData.json").ToJsonObject();

            var features = jsonObject["features"];

            var firstFeature = features.ArrayValue.First();

            var properties = firstFeature.ObjectValue["properties"].ObjectValue;

            var properties2 = properties.With("ID", new JsonValue("newid"));

            var firstFeature2 = firstFeature.ObjectValue.With("properties", new JsonValue(properties2));

            var jsonObject2 = jsonObject.With("features", new JsonValue(new List<JsonValue> { new JsonValue(firstFeature2) }.ToImmutableList()));

            var mutatedJson = jsonObject2.ToJson(true);

            Assert.AreEqual(expectedJson, mutatedJson);
        }

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

            Assert.AreEqual((decimal)145.07016,
                coordinatesArray.First().NumberValue);

            Console.WriteLine(jsonObject.ToJson(false));
            Console.WriteLine();

            var formattedJson = jsonObject.ToJson(true);

            Assert.AreEqual(originalJson, formattedJson);

            Console.WriteLine(formattedJson);
        }
    }
}




