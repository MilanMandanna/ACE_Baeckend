using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace backend.Worker.Helper
{
   public class MD5HashingHelper
    {

        static public string GetMd5Hash(string Filename)
        {
            // Create a new instance of the MD5CryptoServiceProvider object.
            MD5 md5Hasher = MD5.Create();

            FileStream objFileStream = new FileStream(Filename, FileMode.Open);

            // Convert the input string to a byte array and compute the hash.
            byte[] data = md5Hasher.ComputeHash(objFileStream);

            // Create a new Stringbuilder to collect the bytes
            // and create a string.
            StringBuilder sBuilder = new StringBuilder();

            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            objFileStream.Flush();
            objFileStream.Close();
            // Return the hexadecimal string.
            return sBuilder.ToString();

           
        }

    }
}
