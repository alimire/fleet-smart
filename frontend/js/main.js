// Fleet Smart Frontend JavaScript
// Connects to Odoo backend API for real-time fleet data

class FleetSmartAPI {
    constructor() {
        // Configure your Odoo backend URL here
        this.baseURL = 'https://your-odoo-backend.com'; // Replace with your actual backend URL
        this.apiEndpoint = '/web/dataset/call_kw';
        
        // Initialize the app
        this.init();
    }

    async init() {
        console.log('🚗 Fleet Smart Frontend Initialized');
        
        // Load initial data
        await this.loadFleetStats();
        await this.loadFleetVehicles();
        
        // Set up event listeners
        this.setupEventListeners();
        
        // Start real-time updates
        this.startRealTimeUpdates();
    }

    setupEventListeners() {
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Contact form handling
        const contactForm = document.getElementById('contact-form');
        if (contactForm) {
            contactForm.addEventListener('submit', this.handleContactForm.bind(this));
        }

        // Add scroll effects
        this.setupScrollAnimations();
    }

    setupScrollAnimations() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in-up');
                }
            });
        }, observerOptions);

        // Observe all cards and sections
        document.querySelectorAll('.feature-card, .vehicle-card, .stat-card').forEach(card => {
            observer.observe(card);
        });
    }

    async loadFleetStats() {
        try {
            console.log('📊 Loading fleet statistics...');
            
            // Mock data for demo - replace with actual API call
            const stats = await this.mockFleetStats();
            
            // Update UI
            document.getElementById('total-vehicles').textContent = stats.totalVehicles;
            document.getElementById('available-vehicles').textContent = stats.availableVehicles;
            document.getElementById('avg-battery').textContent = `${stats.avgBattery}%`;
            
            console.log('✅ Fleet statistics loaded');
        } catch (error) {
            console.error('❌ Error loading fleet stats:', error);
            this.showError('Failed to load fleet statistics');
        }
    }

    async loadFleetVehicles() {
        try {
            console.log('🚙 Loading fleet vehicles...');
            
            // Mock data for demo - replace with actual API call
            const vehicles = await this.mockFleetVehicles();
            
            // Update UI
            this.renderVehicles(vehicles);
            
            console.log('✅ Fleet vehicles loaded');
        } catch (error) {
            console.error('❌ Error loading fleet vehicles:', error);
            this.showError('Failed to load fleet vehicles');
        }
    }

    renderVehicles(vehicles) {
        const container = document.getElementById('fleet-vehicles');
        
        if (vehicles.length === 0) {
            container.innerHTML = `
                <div class="col-12 text-center">
                    <p class="text-muted">No vehicles found in the fleet.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = vehicles.map(vehicle => `
            <div class="col-lg-4 col-md-6 mb-4">
                <div class="vehicle-card p-4 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0">${vehicle.license_plate}</h5>
                        <span class="badge ${this.getStatusBadgeClass(vehicle.status)}">
                            ${this.formatStatus(vehicle.status)}
                        </span>
                    </div>
                    <div class="vehicle-details mb-4">
                        <p class="mb-2">
                            <i class="fa fa-car me-2 text-primary"></i>
                            <strong>${vehicle.model}</strong>
                        </p>
                        <p class="mb-2">
                            <i class="fa fa-user me-2 text-info"></i>
                            ${vehicle.driver || 'Unassigned'}
                        </p>
                        <p class="mb-3">
                            <i class="fa fa-map-marker me-2 text-danger"></i>
                            ${vehicle.location || 'Unknown'}
                        </p>
                    </div>
                    <div class="battery-section">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="fw-bold">Battery Level</span>
                            <span class="fw-bold">${vehicle.battery_level}%</span>
                        </div>
                        <div class="progress mb-3">
                            <div class="progress-bar ${this.getBatteryClass(vehicle.battery_level)}" 
                                 style="width: ${vehicle.battery_level}%"></div>
                        </div>
                    </div>
                </div>
            </div>
        `).join('');
    }

    getStatusBadgeClass(status) {
        const statusClasses = {
            'available': 'bg-success',
            'in_use': 'bg-warning',
            'charging': 'bg-info',
            'maintenance': 'bg-secondary'
        };
        return statusClasses[status] || 'bg-secondary';
    }

    formatStatus(status) {
        return status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
    }

    getBatteryClass(batteryLevel) {
        if (batteryLevel > 50) return 'bg-success';
        if (batteryLevel > 20) return 'bg-warning';
        return 'bg-danger';
    }

    async handleContactForm(e) {
        e.preventDefault();
        
        const form = e.target;
        const formData = new FormData(form);
        const submitBtn = form.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        
        // Show loading state
        submitBtn.innerHTML = '<span class="loading"></span> Sending...';
        submitBtn.disabled = true;
        
        try {
            // Simulate form submission - replace with actual API call
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Show success message
            this.showSuccess('Thank you for your message! We will get back to you soon.');
            form.reset();
            
        } catch (error) {
            console.error('❌ Error sending message:', error);
            this.showError('Failed to send message. Please try again.');
        } finally {
            // Reset button
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
        }
    }

    startRealTimeUpdates() {
        // Update fleet data every 30 seconds
        setInterval(() => {
            this.loadFleetStats();
            this.loadFleetVehicles();
        }, 30000);
        
        console.log('🔄 Real-time updates started (30s interval)');
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type) {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `alert alert-${type === 'success' ? 'success' : 'danger'} position-fixed`;
        notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
        notification.innerHTML = `
            <div class="d-flex align-items-center">
                <i class="fa fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'} me-2"></i>
                ${message}
                <button type="button" class="btn-close ms-auto" onclick="this.parentElement.parentElement.remove()"></button>
            </div>
        `;
        
        document.body.appendChild(notification);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }

    // Mock API methods - Replace these with actual Odoo API calls
    async mockFleetStats() {
        // Simulate API delay
        await new Promise(resolve => setTimeout(resolve, 500));
        
        return {
            totalVehicles: 12,
            availableVehicles: 8,
            avgBattery: 76
        };
    }

    async mockFleetVehicles() {
        // Simulate API delay
        await new Promise(resolve => setTimeout(resolve, 800));
        
        return [
            {
                id: 1,
                license_plate: 'EV-001',
                model: 'Tesla Model 3',
                driver: 'John Doe',
                location: 'Downtown Office',
                battery_level: 85,
                status: 'available'
            },
            {
                id: 2,
                license_plate: 'EV-002',
                model: 'Nissan Leaf',
                driver: 'Jane Smith',
                location: 'Warehouse',
                battery_level: 92,
                status: 'in_use'
            },
            {
                id: 3,
                license_plate: 'EV-003',
                model: 'BMW i3',
                driver: 'Mike Johnson',
                location: 'Charging Station A',
                battery_level: 45,
                status: 'charging'
            },
            {
                id: 4,
                license_plate: 'EV-004',
                model: 'Tesla Model Y',
                driver: null,
                location: 'Service Center',
                battery_level: 23,
                status: 'maintenance'
            },
            {
                id: 5,
                license_plate: 'EV-005',
                model: 'Hyundai Kona Electric',
                driver: 'Sarah Wilson',
                location: 'Client Site B',
                battery_level: 67,
                status: 'in_use'
            },
            {
                id: 6,
                license_plate: 'EV-006',
                model: 'Volkswagen ID.4',
                driver: null,
                location: 'Main Depot',
                battery_level: 89,
                status: 'available'
            }
        ];
    }

    // Actual Odoo API methods - Uncomment and configure when ready
    /*
    async callOdooAPI(model, method, args = [], kwargs = {}) {
        const response = await fetch(`${this.baseURL}${this.apiEndpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                jsonrpc: '2.0',
                method: 'call',
                params: {
                    model: model,
                    method: method,
                    args: args,
                    kwargs: kwargs
                }
            })
        });
        
        const data = await response.json();
        if (data.error) {
            throw new Error(data.error.message);
        }
        
        return data.result;
    }

    async getFleetVehicles() {
        return await this.callOdooAPI('fleet.vehicle', 'search_read', [], {
            fields: ['license_plate', 'model_id', 'driver_id', 'location', 'battery_level', 'state_id']
        });
    }
    */
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new FleetSmartAPI();
});

// Add some utility functions
window.FleetSmartUtils = {
    formatBatteryLevel: (level) => {
        return `${Math.round(level)}%`;
    },
    
    formatDistance: (meters) => {
        if (meters < 1000) {
            return `${Math.round(meters)}m`;
        }
        return `${(meters / 1000).toFixed(1)}km`;
    },
    
    getTimeAgo: (timestamp) => {
        const now = new Date();
        const time = new Date(timestamp);
        const diffInSeconds = Math.floor((now - time) / 1000);
        
        if (diffInSeconds < 60) return 'Just now';
        if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
        if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
        return `${Math.floor(diffInSeconds / 86400)}d ago`;
    }
};