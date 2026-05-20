// Currency helper - stores and formats currency throughout the app
let currencySymbol = '$'; // Default

// Format amount with currency
function formatCurrency(amount) {
    return `${currencySymbol}${parseFloat(amount).toFixed(2)}`;
}

// Load and set currency from user info
async function loadCurrency() {
    try {
        const response = await fetch('/api/current-user');
        const user = await response.json();
        if (user.currency) {
            currencySymbol = user.currency;
        }
    } catch (error) {
        console.error('Error loading currency:', error);
    }
}
