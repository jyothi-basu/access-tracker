"""Email delivery for authentication and account recovery workflows."""

from html import escape

import resend

from app.core.config import get_settings


class EmailService:
    """Send authentication emails through the Resend API."""

    def __init__(self) -> None:
        """Load Resend configuration and configure the SDK."""
        settings = get_settings()
        if not settings.resend_api_key or not settings.resend_from_email:
            raise RuntimeError("Resend email configuration is missing")
        resend.api_key = settings.resend_api_key
        self.from_email = settings.resend_from_email

    def _send(self, to_email: str, subject: str, html: str) -> None:
        """Send one HTML email using the configured sender."""
        resend.Emails.send(
            {
                "from": self.from_email,
                "to": [to_email],
                "subject": subject,
                "html": html,
            }
        )

    def send_verification_otp(self, to_email: str, name: str, otp: str) -> None:
        """Send the one-time code used to verify a new account email."""
        safe_name = escape(name)
        self._send(
            to_email,
            "Verify your AccessTracker account",
            f"<p>Hello {safe_name},</p><p>Your AccessTracker verification code is "
            f"<strong>{otp}</strong>.</p><p>This code expires in 10 minutes.</p>",
        )

    def send_password_reset_otp(self, to_email: str, otp: str) -> None:
        """Send the one-time code used to start password recovery."""
        self._send(
            to_email,
            "Reset your AccessTracker password",
            f"<p>Your AccessTracker password reset code is <strong>{otp}</strong>.</p>"
            "<p>This code expires in 10 minutes. If you did not request this, you can ignore this email.</p>",
        )

    def send_password_changed(self, to_email: str) -> None:
        """Notify the user after a successful password change."""
        self._send(
            to_email,
            "Your AccessTracker password was changed",
            "<p>Your AccessTracker password was successfully changed.</p>"
            "<p>If you did not make this change, contact support immediately.</p>",
        )
