using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace backend.IntegrationTest.Helpers
{
    public static class ClientHelper
    {

        public static async Task<T> GetAsync<T>(this HttpClient client, string url)
        {
            var response = await client.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<T>(content);
            return result;
        }

        public static async Task<T> PostAsyncJson<T>(this HttpClient client, string url, string content)
        {
            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new StringContent(content, Encoding.UTF8, "application/json");
            var response = await client.SendAsync(request);
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<T>(responseContent);
            return result;
        }

        public static async Task<T> PostAsyncJson<T>(this HttpClient client, string url, object jsonObject)
        {
            var data = JsonConvert.SerializeObject(jsonObject);
            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new StringContent(data, Encoding.UTF8, "application/json");
            var response = await client.SendAsync(request);
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<T>(responseContent);
            return result;
        }

        public static async Task<T> GetAsyncForm<T>(this HttpClient client, string url, Dictionary<string, string> parameters)
        {
            var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Content = new FormUrlEncodedContent(parameters);
            var response = await client.SendAsync(request);
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<T>(responseContent);
            return result;
        }

        public static async Task<T> PostAsyncForm<T>(this HttpClient client, string url, Dictionary<string, string> parameters)
        {
            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new FormUrlEncodedContent(parameters);
            var response = await client.SendAsync(request);
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<T>(responseContent);
            return result;
        }

    }
}
