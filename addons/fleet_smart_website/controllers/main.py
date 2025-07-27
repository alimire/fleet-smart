from odoo import http
from odoo.http import request

class FleetSmartWebsite(http.Controller):

    @http.route('/', type='http', auth="public", website=True)
    def index(self, **kw):
        """Homepage - Fleet Smart landing page"""
        try:
            # Try to get fleet vehicles if fleet module is installed
            vehicles = request.env['fleet.vehicle'].sudo().search([])
            total_vehicles = len(vehicles)
            available_vehicles = len(vehicles.filtered(lambda v: v.state_id.name == 'Available' if v.state_id else False))
        except KeyError:
            # Fleet module not installed, use mock data
            vehicles = []
            total_vehicles = 2
            available_vehicles = 1
        
        # Mock battery data since standard fleet.vehicle doesn't have battery_level
        avg_battery = 78.5  # Mock average battery level
        
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
        try:
            vehicles = request.env['fleet.vehicle'].sudo().search([])
        except KeyError:
            # Fleet module not installed, use empty list
            vehicles = []
        return request.render('fleet_smart_website.fleet_overview', {'vehicles': vehicles})

    @http.route('/vehicle/<int:vehicle_id>', type='http', auth="public", website=True)
    def vehicle_detail(self, vehicle_id, **kw):
        """Individual vehicle details"""
        try:
            vehicle = request.env['fleet.vehicle'].sudo().browse(vehicle_id)
            if not vehicle.exists():
                return request.not_found()
            return request.render('fleet_smart_website.vehicle_detail', {'vehicle': vehicle})
        except KeyError:
            # Fleet module not installed
            return request.not_found()

    @http.route('/about', type='http', auth="public", website=True)
    def about(self, **kw):
        """About page"""
        return request.render('fleet_smart_website.about_page')

    @http.route('/contact', type='http', auth="public", website=True)
    def contact(self, **kw):
        """Contact page"""
        return request.render('fleet_smart_website.contact_page')