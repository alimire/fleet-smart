{
    'name': 'Fleet Smart',
    'version': '1.0',
    'summary': 'Smart EV Fleet Management - Auto Deployed!',
    'category': 'Fleet',
    'author': 'You',
    'license': 'LGPL-3',
    'depends': ['base'],
    'data': [
        'security/security.xml',
        'security/ir.model.access.csv',
        'views/fleet_vehicle_views.xml',
        'data/fleet_data.xml',
    ],
    'installable': True,
    'application': True,
}
