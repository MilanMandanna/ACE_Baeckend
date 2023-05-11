using System;

namespace backend.Mappers.DataTransferObjects.Generic
{
    public class DataDownloadResultDTO
    {
        public Guid Id { get; set; }

        public bool IsError { get; set; }

        public string Message { get; set; }

        public string Data { get; set; }
    }
}
