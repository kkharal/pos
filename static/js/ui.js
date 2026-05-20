// ===== Toast Notification System =====
function _ensureToastContainer() {
    let c = document.getElementById('toast-container');
    if (!c) {
        c = document.createElement('div');
        c.id = 'toast-container';
        c.className = 'toast-container';
        document.body.appendChild(c);
    }
    return c;
}

function _ensureLoadingOverlay() {
    let o = document.getElementById('loading-overlay');
    if (!o) {
        o = document.createElement('div');
        o.id = 'loading-overlay';
        o.className = 'loading-overlay';
        o.innerHTML = '<div class="loading-spinner"></div>';
        document.body.appendChild(o);
    }
    return o;
}

const TOAST_ICONS = {
    success: '✓',
    error: '✕',
    warning: '⚠',
    info: 'ℹ'
};

/**
 * Show a toast notification
 * @param {string} message - The message to display
 * @param {string} type - 'success' | 'error' | 'warning' | 'info'
 * @param {number} duration - Duration in ms (default 3000)
 */
function showToast(message, type = 'info', duration = 3000) {
    const container = _ensureToastContainer();
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.style.setProperty('--toast-duration', (duration / 1000) + 's');
    toast.innerHTML = `
        <span class="toast-icon">${TOAST_ICONS[type] || 'ℹ'}</span>
        <span class="toast-message">${message}</span>
        <button class="toast-close" onclick="this.parentElement.remove()">&times;</button>
    `;
    container.appendChild(toast);

    // Remove after animation completes
    setTimeout(() => {
        if (toast.parentElement) toast.remove();
    }, duration + 300);
}

/**
 * Show loading overlay
 */
function showLoading() {
    _ensureLoadingOverlay().classList.add('active');
}

/**
 * Hide loading overlay
 */
function hideLoading() {
    _ensureLoadingOverlay().classList.remove('active');
}

// ===== Sidebar Toggle =====
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainWrapper = document.getElementById('main-wrapper');
    const overlay = document.getElementById('sidebar-overlay');
    if (!sidebar) return;

    if (window.innerWidth <= 900) {
        // Mobile: slide in/out
        sidebar.classList.toggle('mobile-open');
        if (overlay) overlay.classList.toggle('active');
    } else {
        // Desktop: collapse to icon-only
        const isCollapsed = sidebar.classList.toggle('collapsed');
        if (mainWrapper) mainWrapper.classList.toggle('sidebar-collapsed', isCollapsed);
        try { localStorage.setItem('sidebar_collapsed', isCollapsed ? '1' : '0'); } catch(e) {}
    }
}

function closeSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    if (sidebar) sidebar.classList.remove('mobile-open');
    if (overlay) overlay.classList.remove('active');
}

// Restore sidebar state on page load
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const mainWrapper = document.getElementById('main-wrapper');
    if (!sidebar) return;
    if (window.innerWidth > 900) {
        try {
            if (localStorage.getItem('sidebar_collapsed') === '1') {
                sidebar.classList.add('collapsed');
                if (mainWrapper) mainWrapper.classList.add('sidebar-collapsed');
            }
        } catch(e) {}
    }
});

// Close any active modal when clicking the backdrop (outside modal-content)
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal') && e.target.classList.contains('active')) {
        e.target.classList.remove('active');
    }
});

// ===== Role helpers =====
/** Check if a role has admin-level permissions (admin, shop_owner, super_admin) */
function isAdminRole(role) {
    return role === 'admin' || role === 'super_admin' || role === 'shop_owner';
}

/** Check if a role can see the shop switcher (shop_owner, super_admin) */
function isMultiShopRole(role) {
    return role === 'super_admin' || role === 'shop_owner';
}

/** Get display label for a role */
function getRoleLabel(role) {
    if (role === 'super_admin') return 'Super Admin';
    if (role === 'shop_owner') return 'Shop Owner';
    if (role === 'admin') return 'Administrator';
    return 'Sales Staff';
}

/** Get role badge CSS class */
function getRoleBadgeClass(role) {
    if (role === 'super_admin') return 'role-badge super-admin';
    if (role === 'shop_owner') return 'role-badge shop-owner';
    if (role === 'admin') return 'role-badge admin';
    return 'role-badge user';
}
