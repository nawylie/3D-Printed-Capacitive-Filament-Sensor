// Comb Capacitor
// Idealized capacitance calculations
// Modeled as several parallel plates

// Ideal Capacitance (pF)
idealCapacitance = 100;
// Height of capacitor (mm)
fingerHeight = 50;
// Length of each finger (mm)
fingerLength = 10;
// Width of each finger (mm)
fingerWidth = 0.8;
// Air gap between fingers (mm)
dielectricGap = 0.8;
// Text size
textSize = 3;

// normalized parameters to Farads and Meters
NidealCapacitance = idealCapacitance * pow(10, -12);
NfingerHeight = fingerHeight / 1000;
NfingerLength = fingerLength / 1000;
NfingerWidth = fingerWidth / 1000;
NdielectricGap = dielectricGap / 1000;

// max overlap area of each plate
overlapAreaPlate = NfingerHeight * (NfingerLength - NdielectricGap);
    
// Permittivity of free space
Eo = 8.854 * pow(10, -12); 
    
// Dielectric Constant of Air
K = 1.00059;

// Dielectric Constant of PLA plastic
// https://www.zhinst.com/americas/ko/blogs/measuring-dielectric-properties-materials-varying-thickness
//K = 2.7;

// Calculate capacitence per parallel plates
cPlate = (K*Eo*overlapAreaPlate) / NdielectricGap;
echo(cPlate);

// Calculate number of parallel plates needed
echo(ceil(NidealCapacitance / cPlate));
numPlates = ceil(ceil(NidealCapacitance / cPlate)/2);
echo(numPlates);

// Calculate length of the comb spine
spineLength = numPlates * 2 *(fingerWidth + dielectricGap) + fingerWidth;

module BasePlate() {
    union () {
        translate([-fingerWidth*2, 0, -2])
            cube([dielectricGap + fingerLength + fingerWidth*2, spineLength, 1.6]);
    
        //spacers between plates
        for (x = [1:2:numPlates*4]) {
            translate([dielectricGap, x * (fingerWidth) + dielectricGap/4, -2])
                cube([fingerLength-dielectricGap, dielectricGap/2, fingerHeight]);
        }
    }
}    

module CombCap() {
    // comb 1
    union () {
        // spine of comb 1
        union () {
        translate([-fingerWidth*2 ,0, 0])
            cube([fingerWidth*2, spineLength, fingerHeight]);
        
        // value text
        translate([-fingerWidth*2,(fingerWidth*1.5 + dielectricGap),0])
            rotate([90,270,270])
                linear_extrude(0.2)
                    text(text = str(idealCapacitance,"pF"), size = textSize, valign = "center");
        }
        // plates for comb 1
        for (x = [0:numPlates]) {
            translate([0, x * ((3*dielectricGap)+fingerWidth), 0])
                cube([fingerLength, fingerWidth, fingerHeight]);       
        }
        
        // clip location
        translate([(-fingerWidth*2)-10, (spineLength/2)-(3/2), 0])
            cube([10, 3, 5]);
        
        translate([(-fingerWidth*2)-10, (spineLength/2)-(3/2), fingerHeight-5])
            cube([10, 3, 5]);
    }        

    // comb 2
    union (){
        // spine of comb 2
        translate([dielectricGap + fingerLength ,0, 0])
            cube([fingerWidth*2, spineLength, fingerHeight]);
        
        // plates for comb 2
        for (x = [0:numPlates-1]) {
            translate([dielectricGap, fingerWidth + dielectricGap + (x * (3*dielectricGap+fingerWidth)), 0])
                cube([fingerLength, fingerWidth, fingerHeight]);       
        }
        
        // clip location
        translate([dielectricGap + fingerLength + fingerWidth*2, (spineLength/2)-(3/2), 0])
            cube([10, 3, 5]);
        
        translate([dielectricGap + fingerLength + fingerWidth*2, (spineLength/2)-(3/2), fingerHeight-5])
            cube([10, 3, 5]);
    } 
}

color("grey") CombCap();

//color("yellow") BasePlate();