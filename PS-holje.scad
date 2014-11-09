/* ==== Begrepp ====

 I hela filen: bredd <==> x-led
               djup  <==> y-led
               höjd  <==> z-led

 Höljet är delat i två: övderdelen och underdelen.

 Sladdarna kommer in framifrån mellan underdelen och överdelen.

 Från vänster (när man tittar framifrån) kallar vi sladdarna 
    sladd0                     sladd1    sladd2

 Sladd2 är tjock (stor radie), de andra är tunna (lill-radien)

 Sladd0 kläms fast mellan liten_kloss_underdel och liten_kloss_overdel.
 Sladd1 och 2 kläms mellan stor_kloss_underdel och stor_kloss_overdel.

  ==== Kod-stil ====
 Så mycket som möjligt translateras klart så 
 tidigt i koden som möjligt för att underlätta debugging
 (man kan då sätta ihop halvfärdiga delar utan extra insats).

 Efter varje moduldefinition finns ett unvändarexempel. 

*/


/* ====  Värden vi mätt upp ==== */

mutter_bredd = 5.5; 
mutter_hojd = 2.3;  
storr = 3.6;      /* Den stora sladdstorleken                        */
lillr = 1.35;     /* Den lilla sladdstorleken                        */
sladd0_x = 33.05; /* Liten kloss bör ha sin mitt ca på denna x-koord.*/
sladd1_x = 81.25; /* Stor kloss bör ha sin mitt mellan               */
sladd2_x = 96.25; /* sladd1_x och sladd2_x någostans                 */
M4_yneg_underdel = 8; /* M4 är skruvstorleken som går in i power supp*/
M4_z_underdel    = 11.5;
M4_yneg_overdel  = 8.3;
M4_zneg_overdel  = 12.8;

/* ====  Värden vi bestämt själv ==== */

tak_o_golv = 2.25;/* Tjocklek på tak och golv                        */
vaeggar = 1.5;    /* Tjocklek på väggar                              */
stor =  200;      /* Random stort tal, används vid difference ibland */
hoernradie = 5;   /* Yttre radien på runda hörn                      */
slot_tak = 4;     /* Millimeter med plast över mutterlåsen           */
slot_width=mutter_bredd + 0.35; /* gör koden icke-portabel...        */
slot_height=mutter_hojd + 0.35; /* gör koden icke-portabel...        */
M4r = 2.3;                      /* gör koden icke-portabel...        */
liten_kloss_bredd = 20;
liten_kloss_djup = 10;
stor_kloss_bredd = 39;
stor_kloss_djup = liten_kloss_djup;
underdel_hoejd = 20+tak_o_golv;
overdel_hoejd  = 30+tak_o_golv;
total_hoejd    = underdel_hoejd + overdel_hoejd;
innre_bredd = 114;
total_bredd = innre_bredd+2*vaeggar;
total_djup = 65;
haal0_x = 16.55; /* x-transl skruvar jmf vänster-kant på stor_kloss  */
haal1_x = 5.25;  /* Passar redan utskriven del                       */
haal2_x = 32.5;

/* Holes to easier get screws through, as described by nophead       */
module polyhole(h, d) {
    n = max(round(2 * d),3);
    rotate([0,0,180])
        cylinder(h = h, r = (d / 2) / cos (180 / n), $fn = n);
}

/* Används som huvud-kuber i både underdel och överdel               
 * funkar som cube fast två av hörnena är avrundade längs y-axeln    */
module rh_kub(v,r){
  union(){
    translate([r,r,0])      cylinder(r=r,h=v[2]);
    translate([v[0]-r,r,0]) cylinder(r=r,h=v[2]);
    translate([0,r,0])      cube([v[0], v[1]-r,v[2]]);
    translate([r,0,0])      cube([v[0]-2*r,2*r,v[2]]);
  }
}
//rh_kub([70, 40, 15], 14);

/* Används vid difference (för att gröpa ur med).
 * Skapar då hål till de tre sladdarna
 * Translaterad och klar                                             */
module sladdhaal(){
  /* Hål till sladd2                                                 */
  translate([sladd2_x,-stor/2,underdel_hoejd]) rotate([-90,0,0]) 
    cylinder(h = stor, r = storr);
  /* Hål till sladd1                                                 */
  translate([sladd1_x,-stor/2,underdel_hoejd]) rotate([-90,0,0]) 
    cylinder(h = stor, r = lillr, $fn=16); // 16-kantad cylinder
  /* Hål till sladd0                                                 */
  translate([sladd0_x,-stor/2,underdel_hoejd]) rotate([-90,0,0]) 
    cylinder(h = stor, r = lillr, $fn=16); // 16-kantad cylinder
}

/* En bättre (en nivå högre) abstraktion som skulle
 * använts i liten_kloss_split
 * och stor_kloss_split, men OpenScad tillåter inte att
 * child(0) skickas till en icke-inbyggd operator
module split_put(vs){
  union(){
    for(v=vs){
      translate(v)
        child(0);
    }
  }
}
*/
//split_put([[1,0,0],[10,0,0]]) cube(1);

/* Tar ett objekt som är centrerat i xy-planet och placcerar
 * en kopia av det vid varje skruv-position i lillblocket.
 * Ger positioner rakt på lillklossen
 * Inte translaterat och klart                                       */
module liten_kloss_split(){
  koords = [[3*liten_kloss_bredd/4, liten_kloss_djup/2,0],
            [  liten_kloss_bredd/4, liten_kloss_djup/2,0]];
  union(){
    for(v=koords){
      translate(v)
        child(0);
    }
  }
}
//liten_kloss_split() cube(1);

module stor_kloss_split(){
  koords = [[haal0_x, stor_kloss_djup/2,0],
            [haal1_x, stor_kloss_djup/2,0],
            [haal2_x, stor_kloss_djup/2,0]];
  union(){
    for(v=koords){
      translate(v)
        child(0);
    }
  }
}
//stor_kloss_split() cube(1);

// Translationerna som ska göras på liten kloss
module liten_kloss_xy_translate(){
  translate([sladd0_x-liten_kloss_bredd/2, vaeggar,0])
    child(0);
}
//liten_kloss_xy_translate() cube(1);

module stor_kloss_xy_translate(){
  translate([71.75, vaeggar,0]) // skumt hårdkodat x-värde
    child(0);
}
//stor_kloss_xy_translate() cube(1);

/* Används vid difference.
 * Skapar då hål längs de två skruvarna i lillklossen
 * Translatead och klar                                              */
module liten_kloss_skruvhaal(d = 3){
  liten_kloss_xy_translate()
    liten_kloss_split()
      polyhole(d = d, h = stor);
}
//liten_kloss_skruvhaal(d=3);

module stor_kloss_skruvhaal(d = 3){
  stor_kloss_xy_translate()
    stor_kloss_split()
      polyhole(d = d, h = stor);
}
//stor_kloss_skruvhaal(d=3);

/* De delar av liten kloss som är gemensamma för över- och underdelen:
 * - x och y-placcering 
 * - x och y-storlek
 * - 3mm skruvhål rakt igenom                                        */
module liten_kloss(h) { 
    difference(){
      liten_kloss_xy_translate()
        cube([liten_kloss_bredd, liten_kloss_djup, h]);
      translate([0,0,-1]) // Gör skruvhålen genomträngande
        liten_kloss_skruvhaal(d=3);
    }
}
//liten_kloss(10);

module stor_kloss(h) { 
    difference(){
      stor_kloss_xy_translate()
        cube([stor_kloss_bredd, stor_kloss_djup, h]);
      translate([0,0,-1]) // Gör skruvhålen genomträngande
        stor_kloss_skruvhaal(d=3);
    }
}
//stor_kloss(10);



/* De delar av liten kloss som specialanpassas för underdelen
 * - höjd
 * - Skåra på toppen
 * - Mutterlåsar                                                     */
module liten_kloss_underdel(){
  difference(){
    liten_kloss(underdel_hoejd);
    // Mutterlåsen i lillklossen
    translate([0,0,underdel_hoejd-slot_height/2-slot_tak])
      liten_kloss_xy_translate()
        liten_kloss_split()
          cube([slot_width, stor, slot_height], center=true);
    // Skåran till sladd0
      translate([sladd0_x,0,underdel_hoejd])
        rotate([-90,0,0]) rotate([0,0,210])
          cylinder(h = stor, r = lillr, $fn=30);
  }
}
//liten_kloss_underdel();


module stor_kloss_underdel(){
  difference(){
    stor_kloss(underdel_hoejd);
    // Mutterlås storkloss
    translate([0,0,underdel_hoejd-slot_height/2-slot_tak])
      stor_kloss_xy_translate()
        stor_kloss_split()
          cube([slot_width, stor, slot_height], center=true);
    // Skåror till sladd1 och sladd2
    translate([sladd1_x,0,underdel_hoejd]) 
      rotate([-90,0,0]) rotate([0,0,210])
        cylinder(h = stor, r = lillr, $fn=30);
    translate([sladd2_x,0,underdel_hoejd]) 
      rotate([-90,0,0]) rotate([0,0,210])
        cylinder(h = stor, r = storr, $fn=30);
  }
}
//stor_kloss_underdel();



/* De delar av liten kloss som specialanpassas för underdelen
 * - höjd
 * - Skåra på botten
 * - Placcering i z-led
 * (Hål för skruv-huvuden ska genom tak också så vi väntar med dem)  */
module liten_kloss_overdel(){
  translate([0,0,underdel_hoejd])
    difference(){
      liten_kloss(overdel_hoejd);
      // Skåran till sladd0
      translate([sladd0_x,0,0])
          rotate([-90,0,0]) rotate([0,0,30])
            cylinder(h = stor, r = lillr, $fn=3);
    }
}
//liten_kloss_overdel();

module stor_kloss_overdel(){
  translate([0,0,underdel_hoejd])
    difference(){
      stor_kloss(overdel_hoejd);
      // Skåran till sladd1
      translate([sladd1_x,0,0])
        rotate([-90,0,0]) rotate([0,0,30])
          cylinder(h = stor, r = lillr, $fn=3);
      // Skåran till sladd2
      translate([sladd2_x,0,0])
        rotate([-90,0,0]) rotate([0,0,30])
          cylinder(h = stor, r = storr, $fn=3);
    }
}
//stor_kloss_overdel();


module underdel(){
  union(){
    difference(){
      rh_kub([total_bredd, total_djup, underdel_hoejd],hoernradie);
      translate([vaeggar,vaeggar,tak_o_golv]) 
        rh_kub([innre_bredd, total_djup, underdel_hoejd],hoernradie);
      sladdhaal();
      // M4 skruvhål (längs x-axeln)
      translate([-1, total_djup    - M4_yneg_underdel, 
                     M4_z_underdel + tak_o_golv])
        rotate([0,90,0])
          cylinder(r = M4r, h = stor);
    }
    liten_kloss_underdel();
    stor_kloss_underdel();
  }
}
underdel();

module overdel(){
  golv_under_skruvhuvuden = 3;
  difference(){
    union(){
      difference(){
        translate([0,0,underdel_hoejd])
          rh_kub([total_bredd, total_djup, overdel_hoejd],hoernradie);
        translate([vaeggar,vaeggar,underdel_hoejd-tak_o_golv]) 
          rh_kub([innre_bredd, total_djup, overdel_hoejd],hoernradie);
        sladdhaal();
        // M4 skruvhål (längs x-axeln)
        translate([-1, total_djup             - M4_yneg_overdel, 
                       total_hoejd-tak_o_golv - M4_zneg_overdel]) 
          rotate([0,90,0])
            cylinder(r = M4r, h = stor);
      }
      liten_kloss_overdel();
      stor_kloss_overdel();
    }
    translate([0,0,underdel_hoejd + golv_under_skruvhuvuden]){
      stor_kloss_skruvhaal(d = 6);
      liten_kloss_skruvhaal(d = 6);
    }
  }
}
//overdel();

module show(){
  color("deeppink") underdel();
  color("hotpink") overdel();
  // sladd0
  color("blue")
  translate([sladd0_x,-39,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = lillr);
  color("orange")
  translate([sladd0_x,-41,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = lillr-0.3);
  // sladd1
  color("brown")
  translate([sladd1_x,-39,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = lillr);
  color("orange")
  translate([sladd1_x,-41,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = lillr-0.3);
  // sladd2
  color("black")
  translate([sladd2_x,-39,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = storr);
  color("orange")
  translate([sladd2_x,-41,underdel_hoejd])
    rotate([-90,0,0]) rotate([0,0,30])
      cylinder(h = 40, r = storr-1);
  // skruvar
  color("grey"){
    translate([-40, total_djup             - M4_yneg_overdel, 
                    total_hoejd-tak_o_golv - M4_zneg_overdel]) 
      rotate([0,90,0])
        cylinder(r = M4r, h = 35);
    translate([-40, total_djup             - M4_yneg_overdel, 
                    total_hoejd-tak_o_golv - M4_zneg_overdel]) 
      rotate([0,90,0])
        cylinder(r = M4r+2, h = 5);
    translate([total_bredd + 5, total_djup - M4_yneg_overdel, 
                    total_hoejd-tak_o_golv - M4_zneg_overdel]) 
      rotate([0,90,0])
        cylinder(r = M4r, h = 35);
    translate([total_bredd + 35, total_djup - M4_yneg_overdel, 
                    total_hoejd-tak_o_golv  - M4_zneg_overdel]) 
      rotate([0,90,0])
        cylinder(r = M4r+2, h = 5);

    translate([-40, total_djup             - M4_yneg_underdel, 
                    M4_z_underdel+tak_o_golv]) 
      rotate([0,90,0])
        cylinder(r = 2, h = 35);
    translate([-40, total_djup             - M4_yneg_underdel, 
                    M4_z_underdel+tak_o_golv]) 
      rotate([0,90,0])
        cylinder(r = 4, h = 5);
    translate([total_bredd + 5, total_djup - M4_yneg_underdel, 
                    M4_z_underdel+tak_o_golv]) 
      rotate([0,90,0])
        cylinder(r = 2, h = 35);
    translate([total_bredd + 35, total_djup - M4_yneg_underdel, 
                    M4_z_underdel+tak_o_golv]) 
      rotate([0,90,0])
        cylinder(r = 4, h = 5);
    translate([0,0,total_hoejd+5]){
      stor_kloss_xy_translate()
        stor_kloss_split()
          cylinder(r = 1.5, h = 26);
      liten_kloss_xy_translate()
        liten_kloss_split()
          cylinder(r = 1.5, h = 26);
      difference(){
        translate([0,0,25]){
          stor_kloss_xy_translate()
            stor_kloss_split()
              cylinder(r = 3, h = 5);
          liten_kloss_xy_translate()
            liten_kloss_split()
              cylinder(r = 3, h = 5);
        }
        translate([0,0,26.5]){
          stor_kloss_xy_translate()
            stor_kloss_split()
              cylinder(r = 1.8, h = stor, $fn=6);
          liten_kloss_xy_translate()
            liten_kloss_split()
              cylinder(r = 1.8, h = stor, $fn=6);
        }
      }
    }
  }
}
//show();
