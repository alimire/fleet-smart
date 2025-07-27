from odoo import http
from odoo.http import request

class FleetWebsiteSimple(http.Controller):

    @http.route('/', type='http', auth="public", website=True)
    def homepage(self, **kw):
        vehicles = request.env['fleet.smart.vehicle'].sudo().search([])
        return f"""
        <html>
        <head>
            <title>Fleet Smart - EV Management</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }}
                .container {{ max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }}
                .header {{ text-align: center; margin-bottom: 40px; }}
                .header h1 {{ color: #2c3e50; font-size: 3em; margin: 0; }}
                .header p {{ color: #7f8c8d; font-size: 1.2em; }}
                .stats {{ display: flex; justify-content: space-around; margin: 40px 0; }}
                .stat {{ text-align: center; padding: 20px; background: #3498db; color: white; border-radius: 10px; }}
                .vehicles {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }}
                .vehicle {{ background: white; border: 1px solid #ddd; border-radius: 10px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }}
                .battery {{ background: #ecf0f1; border-radius: 10px; height: 20px; margin: 10px 0; }}
                .battery-fill {{ height: 100%; border-radius: 10px; }}
                .available {{ background: #27ae60; }}
                .in_use {{ background: #f39c12; }}
                .charging {{ background: #3498db; }}
                .maintenance {{ background: #e74c3c; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🚗 Fleet Smart</h1>
                    <p>Advanced Electric Vehicle Fleet Management</p>
                </div>
                
                <div class="stats">
                    <div class="stat">
                        <h2>{len(vehicles)}</h2>
                        <p>Total Vehicles</p>
                    </div>
                    <div class="stat">
                        <h2>{len([v for v in vehicles if v.status == 'available'])}</h2>
                        <p>Available</p>
                    </div>
                    <div class="stat">
                        <h2>{round(sum(v.battery_level for v in vehicles) / len(vehicles) if vehicles else 0, 1)}%</h2>
                        <p>Avg Battery</p>
                    </div>
                </div>
                
                <h2>Our Fleet</h2>
                <div class="vehicles">
                    {''.join([f'''
                    <div class="vehicle">
                        <h3>{v.license_plate} - {v.model}</h3>
                        <p><strong>Driver:</strong> {v.driver}</p>
                        <p><strong>Location:</strong> {v.location}</p>
                        <p><strong>Status:</strong> <span class="{v.status}">{v.status.replace('_', ' ').title()}</span></p>
                        <div class="battery">
                            <div class="battery-fill" style="width: {v.battery_level}%; background: {'#27ae60' if v.battery_level > 50 else '#f39c12' if v.battery_level > 20 else '#e74c3c'};"></div>
                        </div>
                        <p><strong>Battery:</strong> {v.battery_level}%</p>
                    </div>
                    ''' for v in vehicles])}
                </div>
                
                <div style="text-align: center; margin-top: 40px;">
                    <p>Powered by Fleet Smart EV Management System</p>
                </div>
            </div>
        </body>
        </html>
        """