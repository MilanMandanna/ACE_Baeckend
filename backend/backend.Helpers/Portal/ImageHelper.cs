using NLog;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace backend.DataLayer.Helpers
{
    public class ImageHelper
    {
        public static Image ResizeImage(Image image, int width, int height, bool needToFill = true)
        {
            if (width == 0)
                width = (int)Math.Round((double)(image.Width * height / image.Height), MidpointRounding.AwayFromZero);
            if (height == 0)
                height = (int)Math.Round((double)(image.Height * width / image.Width), MidpointRounding.AwayFromZero);

            int sourceWidth = image.Width;
            int sourceHeight = image.Height;
            int sourceX = 0;
            int sourceY = 0;
            double destX = 0;
            double destY = 0;

            double nScale = 0;
            double nScaleW = 0;
            double nScaleH = 0;

            nScaleW = width / (double)sourceWidth;
            nScaleH = height / (double)sourceHeight;
            if (!needToFill)
            {
                nScale = Math.Min(nScaleH, nScaleW);
            }
            else
            {
                nScale = Math.Max(nScaleH, nScaleW);
                destY = (height - sourceHeight * nScale) / 2;
                destX = (width - sourceWidth * nScale) / 2;
                //if (destY < 0) destY = 0;
                //if (destX < 0) destX = 0;
            }

            int destWidth = (int)Math.Round(sourceWidth * nScale);
            int destHeight = (int)Math.Round(sourceHeight * nScale);

            Bitmap bmPhoto = null;
            try
            {
                bmPhoto = new Bitmap(destWidth + (int)Math.Round(2 * destX), destHeight + (int)Math.Round(2 * destY));
            }
            catch (Exception ex)
            {
                Logger logger = LogManager.GetLogger("ExceptionLogger");
                logger.Error(ex, $"Error during image resize. {Environment.NewLine} destWidth:{destWidth}, destX:{destX}, destHeight:{destHeight}, desxtY:{destY}, Width:{width}, Height:{height}");
                // throw new ApplicationException($"destWidth:{destWidth}, destX:{destX}, destHeight:{destHeight}, desxtY:{destY}, Width:{width}, Height:{height}", ex);
            }
            using (Graphics grPhoto = Graphics.FromImage(bmPhoto))
            {
                grPhoto.InterpolationMode = InterpolationMode.HighQualityBicubic;
                grPhoto.CompositingQuality = CompositingQuality.HighQuality;
                grPhoto.SmoothingMode = SmoothingMode.HighQuality;
                grPhoto.PixelOffsetMode = PixelOffsetMode.HighQuality;

                Rectangle to = new Rectangle((int)Math.Round(destX), (int)Math.Round(destY), destWidth, destHeight);
                Rectangle from = new Rectangle(sourceX, sourceY, sourceWidth, sourceHeight);
                grPhoto.DrawImage(image, to, from, GraphicsUnit.Pixel);

                return bmPhoto;
            }
        }
    }
}
