/**
 * Session Timeout Management
 * Tracks user activity and automatically logs out after configured inactivity period
 */

let sessionTimeout = 1800; // Default 30 minutes in seconds
let lastActivityTime = Date.now();
let sessionCheckInterval = null;
let warningShown = false;

// Initialize session timeout monitoring
async function initSessionTimeout() {
    try {
        // Get session timeout from server
        const response = await fetch('/api/current-user');
        const user = await response.json();

        if (user.session_timeout) {
            sessionTimeout = user.session_timeout;
        }

        // Reset activity time
        lastActivityTime = Date.now();

        // Track user activity
        trackUserActivity();

        // Check session timeout every 30 seconds
        if (sessionCheckInterval) {
            clearInterval(sessionCheckInterval);
        }
        sessionCheckInterval = setInterval(checkSessionTimeout, 30000);

    } catch (error) {
        console.error('Error initializing session timeout:', error);
    }
}

// Track user activity (mouse, keyboard, touch)
function trackUserActivity() {
    const events = ['mousedown', 'keydown', 'scroll', 'touchstart', 'click'];

    events.forEach(event => {
        document.addEventListener(event, () => {
            lastActivityTime = Date.now();
            warningShown = false;
        }, { passive: true });
    });
}

// Check if session has timed out
function checkSessionTimeout() {
    const currentTime = Date.now();
    const inactiveTime = (currentTime - lastActivityTime) / 1000; // Convert to seconds
    const timeRemaining = sessionTimeout - inactiveTime;

    // Show warning 2 minutes before timeout
    if (timeRemaining <= 120 && timeRemaining > 0 && !warningShown) {
        warningShown = true;
        const minutes = Math.ceil(timeRemaining / 60);
        showTimeoutWarning(minutes);
    }

    // Logout if session has expired
    if (inactiveTime >= sessionTimeout) {
        handleSessionExpired();
    }
}

// Show timeout warning notification
function showTimeoutWarning(minutes) {
    // Check if warning already exists
    if (document.getElementById('session-timeout-warning')) {
        return;
    }

    const warning = document.createElement('div');
    warning.id = 'session-timeout-warning';
    warning.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background-color: #fff3cd;
        color: #856404;
        padding: 15px 20px;
        border-left: 4px solid #ffc107;
        border-radius: 4px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        z-index: 10000;
        max-width: 350px;
        animation: slideIn 0.3s ease-out;
    `;

    warning.innerHTML = `
        <strong>⚠️ Session Timeout Warning</strong>
        <p style="margin: 8px 0 0 0; font-size: 14px;">
            You will be logged out in ${minutes} minute${minutes > 1 ? 's' : ''} due to inactivity.
            Move your mouse or press any key to stay logged in.
        </p>
    `;

    // Add CSS animation
    if (!document.getElementById('session-timeout-styles')) {
        const style = document.createElement('style');
        style.id = 'session-timeout-styles';
        style.textContent = `
            @keyframes slideIn {
                from {
                    transform: translateX(400px);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
        `;
        document.head.appendChild(style);
    }

    document.body.appendChild(warning);

    // Remove warning after activity or timeout
    setTimeout(() => {
        const warningEl = document.getElementById('session-timeout-warning');
        if (warningEl) {
            warningEl.remove();
        }
    }, 10000);
}

// Handle session expiration
function handleSessionExpired() {
    // Clear interval
    if (sessionCheckInterval) {
        clearInterval(sessionCheckInterval);
    }

    // Show expiration message
    alert('Your session has expired due to inactivity. You will be redirected to the login page.');

    // Redirect to logout
    window.location.href = '/logout';
}

// Initialize on page load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSessionTimeout);
} else {
    initSessionTimeout();
}
