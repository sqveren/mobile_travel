CREATE TABLE IF NOT EXISTS cities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    full_name VARCHAR(220) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tourist_places (
    id VARCHAR(100) PRIMARY KEY,
    city_id BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    importance VARCHAR(10) NOT NULL CHECK (importance IN ('high', 'medium', 'low')),
    category VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    lat NUMERIC(9, 6) NOT NULL,
    lng NUMERIC(9, 6) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tourist_places_city_id ON tourist_places(city_id);
CREATE INDEX IF NOT EXISTS idx_tourist_places_importance ON tourist_places(importance);

INSERT INTO cities (name, country, full_name) VALUES
('Kyiv', 'Ukraine', 'Kyiv, Ukraine'),
('Paris', 'France', 'Paris, France'),
('Tokyo', 'Japan', 'Tokyo, Japan'),
('New York', 'USA', 'New York, USA'),
('Barcelona', 'Spain', 'Barcelona, Spain'),
('Rome', 'Italy', 'Rome, Italy'),
('London', 'UK', 'London, UK'),
('Dubai', 'UAE', 'Dubai, UAE'),
('Prague', 'Czech Republic', 'Prague, Czech Republic'),
('Amsterdam', 'Netherlands', 'Amsterdam, Netherlands')
ON CONFLICT (full_name) DO NOTHING;

INSERT INTO tourist_places (id, city_id, name, importance, category, description, lat, lng) VALUES
('kyiv-st-sophia', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Saint Sophia Cathedral', 'high', 'Culture', 'UNESCO-listed cathedral and one of the main historical landmarks of Kyiv.', 50.452600, 30.514400),
('kyiv-lavra', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Kyiv Pechersk Lavra', 'high', 'Culture', 'Monastery complex with caves, museums, and iconic hilltop viewpoints.', 50.434500, 30.557000),
('kyiv-maidan', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Maidan Nezalezhnosti', 'medium', 'City Walk', 'Central square and practical starting point for exploring downtown Kyiv.', 50.450100, 30.523400),
('kyiv-andriivskyi', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Andriivskyi Descent', 'medium', 'Art', 'Historic street with galleries, crafts, cafes, and a strong local atmosphere.', 50.459600, 30.517600),
('kyiv-motherland', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Motherland Monument', 'medium', 'Scenic', 'Large monument complex with elevated views over the Dnipro river.', 50.426600, 30.563000),
('kyiv-podil', (SELECT id FROM cities WHERE full_name = 'Kyiv, Ukraine'), 'Kontraktova Square', 'low', 'Food', 'Podil district square surrounded by cafes, river access, and walkable streets.', 50.466300, 30.513900),

('paris-eiffel', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Eiffel Tower', 'high', 'Scenic', 'Paris landmark with major riverfront views and central access.', 48.858400, 2.294500),
('paris-louvre', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Louvre Museum', 'high', 'Culture', 'World-famous museum and a good anchor point for a central Paris day.', 48.860600, 2.337600),
('paris-notre-dame', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Notre-Dame Cathedral', 'high', 'Culture', 'Historic cathedral on Ile de la Cite and an easy waypoint on foot.', 48.853000, 2.349900),
('paris-sacre', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Sacre-Coeur', 'medium', 'Scenic', 'Hilltop basilica in Montmartre with broad views over the city.', 48.886700, 2.343100),
('paris-orsay', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Musee d''Orsay', 'medium', 'Art', 'Major art museum near the Seine with strong Impressionist collections.', 48.860000, 2.326600),
('paris-luxembourg', (SELECT id FROM cities WHERE full_name = 'Paris, France'), 'Luxembourg Gardens', 'low', 'Nature', 'Classic garden stop for a slower break between museums and walks.', 48.846200, 2.337100),

('tokyo-sensoji', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'Senso-ji Temple', 'high', 'Culture', 'Historic temple complex in Asakusa and a core first-time stop.', 35.714800, 139.796700),
('tokyo-shibuya', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'Shibuya Crossing', 'high', 'Entertainment', 'Iconic city crossing with dense food, shopping, and nightlife.', 35.659500, 139.700500),
('tokyo-meiji', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'Meiji Shrine', 'medium', 'Culture', 'Forest-lined shrine area that works well with Harajuku and Yoyogi.', 35.676400, 139.699300),
('tokyo-skytree', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'Tokyo Skytree', 'medium', 'Scenic', 'Observation tower with panoramic views and mall access.', 35.710100, 139.810700),
('tokyo-ueno', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'Ueno Park', 'low', 'Nature', 'Large park zone with museums, ponds, and flexible walking routes.', 35.714800, 139.774500),
('tokyo-teamlab', (SELECT id FROM cities WHERE full_name = 'Tokyo, Japan'), 'teamLab Planets', 'medium', 'Art', 'Immersive digital art museum in the Toyosu area.', 35.649200, 139.789300),

('nyc-statue', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'Statue of Liberty Ferry', 'high', 'Culture', 'Departure area for one of New York''s signature landmarks.', 40.699500, -74.039600),
('nyc-central-park', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'Central Park', 'high', 'Nature', 'Large park with many route options between major Manhattan stops.', 40.782900, -73.965400),
('nyc-times-square', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'Times Square', 'medium', 'Entertainment', 'Dense theater and media district that is easiest to understand on the map.', 40.758000, -73.985500),
('nyc-met', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'The Metropolitan Museum of Art', 'medium', 'Art', 'Major museum on the east side of Central Park.', 40.779400, -73.963200),
('nyc-brooklyn', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'Brooklyn Bridge', 'medium', 'Scenic', 'Classic walk with skyline views and clear navigation value.', 40.706100, -73.996900),
('nyc-highline', (SELECT id FROM cities WHERE full_name = 'New York, USA'), 'The High Line', 'low', 'City Walk', 'Elevated promenade linking Chelsea stops and river views.', 40.748000, -74.004800),

('barcelona-sagrada', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'Sagrada Familia', 'high', 'Culture', 'Barcelona''s key landmark and natural center for route planning.', 41.403600, 2.174400),
('barcelona-guell', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'Park Guell', 'high', 'Scenic', 'Hilltop park with Gaudi works and broad city views.', 41.414500, 2.152700),
('barcelona-gothic', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'Gothic Quarter', 'medium', 'City Walk', 'Dense old-town area best explored on foot.', 41.383900, 2.176300),
('barcelona-casa-batllo', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'Casa Batllo', 'medium', 'Art', 'Gaudi building on Passeig de Gracia.', 41.391700, 2.164900),
('barcelona-boqueria', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'La Boqueria', 'low', 'Food', 'Busy market just off La Rambla for local snacks and lunch.', 41.381800, 2.171600),
('barcelona-bunker', (SELECT id FROM cities WHERE full_name = 'Barcelona, Spain'), 'Bunkers del Carmel', 'medium', 'Scenic', 'Popular panoramic viewpoint over Barcelona.', 41.418600, 2.152700),

('rome-colosseum', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'Colosseum', 'high', 'Culture', 'Anchor point for the ancient Rome cluster.', 41.890200, 12.492200),
('rome-forum', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'Roman Forum', 'high', 'Culture', 'Historic ruins adjacent to the Colosseum.', 41.892500, 12.485300),
('rome-trevi', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'Trevi Fountain', 'medium', 'City Walk', 'Central stop that connects easily to the Spanish Steps area.', 41.900900, 12.483300),
('rome-pantheon', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'Pantheon', 'medium', 'Culture', 'Major landmark in the historic center.', 41.898600, 12.476900),
('rome-vatican', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'St. Peter''s Basilica', 'high', 'Culture', 'Key Vatican stop with clear walking routes nearby.', 41.902200, 12.453900),
('rome-trastevere', (SELECT id FROM cities WHERE full_name = 'Rome, Italy'), 'Trastevere', 'low', 'Food', 'Neighborhood for evening dining and relaxed walks.', 41.889700, 12.470000),

('london-buckingham', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'Buckingham Palace', 'high', 'Culture', 'Royal landmark near St James''s Park and Westminster.', 51.501400, -0.141900),
('london-westminster', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'Big Ben and Westminster', 'high', 'Culture', 'Central political and sightseeing area by the Thames.', 51.500700, -0.124600),
('london-tower', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'Tower of London', 'high', 'Culture', 'Historic fortress beside Tower Bridge.', 51.508100, -0.075900),
('london-british', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'British Museum', 'medium', 'Art', 'Major museum in Bloomsbury with easy Underground access.', 51.519400, -0.127000),
('london-covent', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'Covent Garden', 'low', 'Entertainment', 'Walkable district for food, shops, and street performance.', 51.511700, -0.124000),
('london-sky', (SELECT id FROM cities WHERE full_name = 'London, UK'), 'Sky Garden', 'medium', 'Scenic', 'Elevated viewpoint in the City with skyline perspectives.', 51.510700, -0.083700),

('dubai-burj', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Burj Khalifa', 'high', 'Scenic', 'Defining skyline landmark in Downtown Dubai.', 25.197200, 55.274400),
('dubai-mall', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Dubai Mall', 'high', 'Entertainment', 'Large retail and leisure hub beside Burj Khalifa.', 25.198500, 55.279600),
('dubai-marina', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Dubai Marina Walk', 'medium', 'City Walk', 'Waterfront route with dining and evening views.', 25.080000, 55.140300),
('dubai-palm', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Palm Jumeirah Boardwalk', 'medium', 'Scenic', 'Coastal perspective over Palm Jumeirah and the skyline.', 25.112400, 55.138400),
('dubai-future', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Museum of the Future', 'medium', 'Art', 'Contemporary landmark on Sheikh Zayed Road.', 25.220400, 55.281200),
('dubai-creek', (SELECT id FROM cities WHERE full_name = 'Dubai, UAE'), 'Al Seef', 'low', 'Food', 'Dubai Creek promenade blending older quarters and dining.', 25.263400, 55.301100),

('prague-castle', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Prague Castle', 'high', 'Culture', 'Castle district overlooking the city and river.', 50.090000, 14.400900),
('prague-charles', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Charles Bridge', 'high', 'Scenic', 'Main pedestrian bridge between Old Town and Mala Strana.', 50.086500, 14.411400),
('prague-square', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Old Town Square', 'high', 'City Walk', 'Historic center with easy orientation for first-time visitors.', 50.087000, 14.420800),
('prague-astronomical', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Astronomical Clock', 'medium', 'Culture', 'Old Town landmark located directly on the main square.', 50.087000, 14.420800),
('prague-petrin', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Petrin Lookout Tower', 'medium', 'Scenic', 'Hilltop park area with broad city panoramas.', 50.083500, 14.395500),
('prague-naplavka', (SELECT id FROM cities WHERE full_name = 'Prague, Czech Republic'), 'Naplavka Riverfront', 'low', 'Food', 'Popular riverside stretch for cafes, walks, and local atmosphere.', 50.072300, 14.414700),

('amsterdam-rijks', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'Rijksmuseum', 'high', 'Art', 'Major museum and strong starting point for Museumplein.', 52.360000, 4.885200),
('amsterdam-vangogh', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'Van Gogh Museum', 'high', 'Art', 'Core museum stop beside Rijksmuseum.', 52.358400, 4.881100),
('amsterdam-dam', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'Dam Square', 'medium', 'City Walk', 'Central orientation point near the historic core.', 52.373100, 4.892200),
('amsterdam-anne', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'Anne Frank House', 'medium', 'Culture', 'Historic museum on one of the central canals.', 52.375200, 4.884000),
('amsterdam-vondel', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'Vondelpark', 'low', 'Nature', 'Large urban park for a slower walking segment.', 52.358000, 4.868600),
('amsterdam-aadam', (SELECT id FROM cities WHERE full_name = 'Amsterdam, Netherlands'), 'A''DAM Lookout', 'medium', 'Scenic', 'Observation point across the IJ with broad city views.', 52.384700, 4.901000)
ON CONFLICT (id) DO NOTHING;

SELECT c.full_name, tp.id, tp.name, tp.importance, tp.category, tp.lat, tp.lng
FROM tourist_places tp
JOIN cities c ON c.id = tp.city_id
ORDER BY c.full_name, tp.name;
