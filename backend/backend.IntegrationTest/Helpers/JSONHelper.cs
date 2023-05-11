using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using FluentAssertions.Json;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json.Linq;

namespace backend.IntegrationTest.Helpers
{
    public class JSONHelper
    {

        public static void TestEquivalent(string actualJson, string expectedJson)
        {
            JToken actual = JToken.Parse(actualJson);
            JToken expected = JToken.Parse(expectedJson);
            actual.Should().BeEquivalentTo(expected);
        }

        public static async Task ResponseEquivalent(HttpResponseMessage response, string expectedJson)
        {
            var content = await response.Content.ReadAsStringAsync();
            TestEquivalent(content, expectedJson);
        }

        public static void IsAssignableTo(string actualJson, string expectedJson)
        {
            JToken actual = JToken.Parse(actualJson);
            JToken expected = JToken.Parse(expectedJson);
            actual.Should().ContainSubtree(expected);
        }

    }
}
