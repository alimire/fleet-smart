from odoo import models, fields, api

class FleetSmartVehicle(models.Model):
    _name = 'fleet.smart.vehicle'
    _description = 'Smart EV Fleet Vehicle'
    _rec_name = 'license_plate'

    license_plate = fields.Char(string='License Plate', required=True)
    model = fields.Char(string='Vehicle Model', required=True)
    driver = fields.Char(string='Driver Name')
    battery_level = fields.Float(string='Battery Level (%)', default=100.0)
    location = fields.Char(string='Current Location')
    status = fields.Selection([
        ('available', 'Available'),
        ('in_use', 'In Use'),
        ('charging', 'Charging'),
        ('maintenance', 'Maintenance')
    ], string='Status', default='available')
    
    @api.model
    def create(self, vals):
        return super(FleetSmartVehicle, self).create(vals)