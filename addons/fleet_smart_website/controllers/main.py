from odoo import http
from odoo.http import request

class FleetSmartWebsite(http.Controller):

    @http.route('/', type='http', auth="public", website=True)
    def index(self, **kw):
        """Homepage - Fleet Smart landing page"""
        vehicles = request.env['fleet.smart.vehicle'].sudo().search([])
        
        # Calculate fleet statistics
        total_vehicles = len(vehicles)
        available_vehicles = len(vehicles.filtered(lambda v: v.status == 'available'))
        avg_battery = sum(vehicles.mapped('battery_level')) / total_vehicles if total_vehicles else 0
        
        values = {
            'vehicles': vehicles,
            'total_vehicles': total_vehicles,
            'available_vehicles': available_vehicles,
            'avg_battery': round(avg_battery, 1),
        }
        return request.render('fleet_smart_website.homepage', values)

    @http.route('/fleet', type='http', auth="public", website=True)
    def fleet_overview(self, **kw):
        """Public fleet overview page"""
        vehicles = request.env['fleet.smart.vehicle'].sudo().search([])
        return request.render('fleet_smart_website.fleet_overview', {'vehicles': vehicles})

    @http.route('/vehicle/<int:vehicle_id>', type='http', auth="public", website=True)
    def vehicle_detail(self, vehicle_id, **kw):
        """Individual vehicle details"""
        vehicle = request.env['fleet.smart.vehicle'].sudo().browse(vehicle_id)
        if not vehicle.exists():
            return request.not_found()
        return request.render('fleet_smart_website.vehicle_detail', {'vehicle': vehicle})

    @http.route('/about', type='http', auth="public", website=True)
    def about(self, **kw):
        """About page"""
        return request.render('fleet_smart_website.about_page')

    @http.route('/contact', type='http', auth="public", website=True)
    def contact(self, **kw):
        """Contact page"""
        return request.render('fleet_smart_website.contact_page')