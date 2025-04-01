/************ METADATA ************
Silica Gel Container for vase mode

1. Customize your container
2. Print body in vase mode, extrude more filament to increase layer adhesion
3. Print lid without top & bottom layers but 25% gyroid infill

Inspired by https://www.thingiverse.com/thing:3666841


/************ PARAMETERS ************/
// quality of the render, closely related to $fn
quality = 64; // [32, 64, 128, 256]

// what do you want to render?
what_to_render = "all"; // [body, lid, all, assembled]

// size of nozzle
nozzle = 0.4;

// too thick and airflow is bad
body_diameter = 36;

// too long and a brim might be needed
body_height = 36*4;

// height of the lid screw part
lid_height = 4;

// height of the lid head, the part to hold onto
lid_height_head = 1;

// tolerance between lid and body thread.
lid_tolerance = 0.4;

// air holes: related to particle size (opening is reduced by wall thickness)
opening_radius = 3.0;

// shall the openings be inside or outside ("false" is not working with PrusaSlicer, it generates infill every level)
opening_to_outside = true;


/************ ASSEMBLY ************/
if (what_to_render == "body") {
    body();
}
else if (what_to_render == "lid") {
    lid();
}
else if (what_to_render == "all") {
    body();
    translate([body_diameter*1.5, 0, 0.0]) lid();
}
else if (what_to_render == "assembled") {
    #body();
    translate([0, 0, body_height+lid_height_head]) rotate([180,0,0]) lid();
}
else {
    // render nothing
}

// print out effective volume
volume = PI * pow(body_diameter/100, 2)/4 * body_height/100;
echo(str("### Container has a volume of ", round(volume*100)/100, " liter."));
echo(str("### Container will take roughly ", round(volume*100*700)/100, "g of silica gel (2mm pearls)"));


/************ CODE ************/
// simple library to create threads
use <threads.scad>

opening_height = opening_radius;

// using integer rounding to add a flat area between openings, if wanted
openings_add_flat_surface = false;
openings_per_level = openings_add_flat_surface ?
    body_diameter * PI / (opening_radius * 2) :
    floor(body_diameter * PI / (opening_radius * 2));
gap_between_levels = -(opening_height/2);

stagger_degrees = 360/openings_per_level/2;
levels = ceil((body_height-2*lid_height) / (opening_height+gap_between_levels));

module lid() {
    cylinder(d=body_diameter + (opening_to_outside ? opening_radius/5*4 : 0), h=lid_height_head, $fn=quality);
    translate([0, 0, lid_height_head])
    metric_thread(internal=true, diameter=body_diameter+lid_height/3-(2*nozzle+lid_tolerance), pitch=lid_height/1.5, length=lid_height, angle=45, leadin=1);
}

module body() {
    difference() {
        // actual container body
        cylinder(d=body_diameter, h=body_height, $fn=quality);
        
        if (!opening_to_outside) air_holes();
    }
    if (opening_to_outside) air_holes();
    
    // outer thread
    translate([0, 0, body_height-lid_height])
    metric_thread(internal=false, diameter=body_diameter+lid_height/3, pitch=lid_height/1.5, length=lid_height, angle=45, leadin=3);
}

// air cut outs
module air_holes() {
    for (i = [0:1:levels-1]) {
        rotate([0,0,i*stagger_degrees])
        translate([0,0,i*(opening_height+gap_between_levels)+1]) {
            radius = body_diameter/2;
            sectors = openings_per_level;
            sector_degrees = 360 / sectors;

            for (sector = [1 : sectors]) {
                angle = sector_degrees*sector;
                x_pos = radius*sin(angle);
                y_pos = radius*cos(angle);
                
                translate([x_pos, y_pos])
                cylinder(d1=0, d2=opening_radius, h=opening_height, $fn=quality/4);
            }
        }
    }
}
