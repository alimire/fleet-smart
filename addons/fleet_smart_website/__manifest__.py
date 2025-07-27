{
    'name': 'Fleet Smart Website',
    'version': '1.0',
    'summary': 'Public website for Fleet Smart EV Management',
    'category': 'Website',
    'author': 'You',
    'license': 'LGPL-3',
    'depends': ['website', 'fleet_smart'],
    'data': [
        'views/website_templates.xml',
        'views/website_pages.xml',
        'data/website_data.xml',
    ],
    'assets': {
        'web.assets_frontend': [
            'fleet_smart_website/static/src/css/website.css',
            'fleet_smart_website/static/src/js/website.js',
        ],
    },
    'installable': True,
    'application': False,
}