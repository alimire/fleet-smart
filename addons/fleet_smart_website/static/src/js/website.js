/* Fleet Smart Website JavaScript */

document.addEventListener('DOMContentLoaded', function() {
    
    // Replace footer content with custom Hubsiimotech footer
    function replaceFooter() {
        const footer = document.querySelector('footer');
        if (footer) {
            footer.innerHTML = `
                <div class="container">
                    <div class="row">
                        <div class="col-md-4">
                            <h5 class="text-white">Fleet Smart</h5>
                            <p class="text-muted">Advanced Electric Vehicle Fleet Management</p>
                        </div>
                        <div class="col-md-4">
                            <h6 class="text-white">Quick Links</h6>
                            <ul class="list-unstyled">
                                <li><a href="/" class="text-muted">Home</a></li>
                                <li><a href="/fleet" class="text-muted">Fleet</a></li>
                                <li><a href="/about" class="text-muted">About</a></li>
                                <li><a href="/contact" class="text-muted">Contact</a></li>
                            </ul>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <div class="d-flex align-items-center justify-content-md-end mb-3">
                                <span class="me-2 text-muted">Powered by</span>
                                <img src="/fleet_smart_website/static/img/hubsiimotech-logo.svg" alt="Hubsiimotech" style="height: 30px;"/>
                            </div>
                            <p class="text-muted small">© 2025 Fleet Smart. All rights reserved.</p>
                        </div>
                    </div>
                </div>
            `;
            footer.style.background = '#1A2332';
            footer.style.color = 'white';
            footer.style.padding = '2rem 0';
        }
    }

    // Replace footer immediately and after delays to ensure it loads
    replaceFooter();
    setTimeout(replaceFooter, 500);
    setTimeout(replaceFooter, 1000);
    
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            document.querySelector(this.getAttribute('href')).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });
    
    // Auto-refresh battery levels every 30 seconds
    if (window.location.pathname === '/fleet' || window.location.pathname === '/') {
        setInterval(function() {
            // Add subtle animation to battery bars
            document.querySelectorAll('.progress-bar').forEach(bar => {
                bar.style.transition = 'width 0.5s ease';
            });
        }, 30000);
    }
    
    // Add loading animation to buttons
    document.querySelectorAll('.btn').forEach(button => {
        button.addEventListener('click', function() {
            if (this.type !== 'submit') {
                const originalText = this.innerHTML;
                this.innerHTML = '<span class="loading"></span> Loading...';
                this.disabled = true;
                
                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.disabled = false;
                }, 1000);
            }
        });
    });
    
    // Contact form handling
    const contactForm = document.querySelector('.contact-form form');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerHTML;
            
            submitBtn.innerHTML = '<span class="loading"></span> Sending...';
            submitBtn.disabled = true;
            
            // Simulate form submission
            setTimeout(() => {
                alert('Thank you for your message! We will get back to you soon.');
                this.reset();
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }, 2000);
        });
    }
    
    // Add fade-in animation to cards
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe all cards for animation
    document.querySelectorAll('.vehicle-card, .feature-card, .stat-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
    
    // Battery level color coding
    document.querySelectorAll('.progress-bar').forEach(bar => {
        const width = parseFloat(bar.style.width);
        if (width > 70) {
            bar.classList.add('bg-success');
        } else if (width > 30) {
            bar.classList.add('bg-warning');
        } else {
            bar.classList.add('bg-danger');
        }
    });
    
});