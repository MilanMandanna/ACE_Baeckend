using System;

namespace backend.Helpers
{
    public static class Constants
    {
        #region ValidationErrorCode

        public static string NotAllowedValue => "VALUE_NOT_ALLOWED";
        public static string AlphaNumericAllowed => "ONLY_ALPHANUMERIC_ALLOWED";
        public static string DateIntervalViolation => "DATE_INTERVAL_VIOLATION";
        public static string ReadOnlyDateViolation => "READONLY_DATE_VIOLATION";
        public static string EmailPolicyViolation => "EMAIL_POLICY_VIOLATION";
        public static string EmailExists => "EMAIL_EXISTS";
        public static string UserNameExists => "USERNAME_EXISTS";
        public static string UserNameDoesNotExists => "USERNAME_DOES_NOT_EXISTS";
        public static string NotEmpty => "EMPTY_NOT_ALLOWED";
        public static string PasswordPolicyViolation => "PASSWORD_POLICY_VIOLATION";
        public static string OldPasswordEqualsNew => "PASSWORDS_SHALL_NOT_EQUAL";
        public static string WrongPassword => "PASSWORD_WRONG";
        public static string PasswordCompareViolation => "PASSWORDS_NOT_EQUAL";
        public static string FormatPolicyViolation => "FORMAT_POLICY_VIOLATION";
        public static string PositiveValueAllowed => "ONLY_POSITIVE_ALLOWED";
        public static string NumericAllowed => "ONLY_NUMERIC_ALLOWED";
        public static string PhonePolicyViolation => "PHONE_POLICY_VIOLATION";
        public static string NotSubscribed => "NOT_SUBSCRIBED";
        public static string EmailSendFailed => "EMAIL_NOT_SENT";
        public static string AircraftsAssigned => "HAS_AIRCRAFTS_ASSIGNED";
        public static string LengthViolation(int from, int to) => $"LENGTH_BETWEEN_{from}_AND_{to}_ALLOWED";
        #endregion
    }
}
