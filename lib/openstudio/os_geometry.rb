#length: double
#width: double
#height: double
#number_of_floors: integer
#perim_and_core: boolean
def create_rectangle(len, width, height, number_of_floors, perim_and_core, perim_depth)
  #do we want to be able to pass in an aspect ratio?
  #make another method
  aspect_ratio = len / width;
  total_area = len * width * number_of_floors;
  floor_plate_area = len * width
  floorprint = []
    
  if not perim_and_core
    floorprint << ["ZN_1", height, 
     			[ 
     			  [0,   0],
    			  [len, 0],
    			  [len, width],
    			  [0,   width]
    			]
    		  ]
  else
    floorprint << ["ZN_1", height, 
     			[
     			  [0,   		    0],
    			  [len,               0],
    			  [len - perim_depth, perim_depth],
    			  [perim_depth,       perim_depth]
    			]
    		  ]
    floorprint << ["ZN_2", height, 
     			[
     			  [len,  		    0],
    			  [len,               width],
    			  [len - perim_depth, width - perim_depth],
    			  [len - perim_depth, perim_depth]
    			]
    		  ]
    floorprint << ["ZN_3", height, 
     			[
     			  [perim_depth,	    width - perim_depth],
    			  [len - perim_depth, width - perim_depth],
    			  [len, 		    width],
    			  [0, 		    width]
    			]
    		  ]
    floorprint << ["ZN_4", height, 
     			[ 
     			  [0,   		    0],
    			  [perim_depth,       perim_depth],
    			  [perim_depth, 	    width - perim_depth],
    			  [0, 		    width]
    			]
    		  ]
    floorprint << ["ZN_5", height, 
     			[
     			  [perim_depth,       perim_depth],
    			  [len - perim_depth, perim_depth],
    			  [len - perim_depth, width - perim_depth],
    			  [perim_depth,       width - perim_depth]
    			]
    		  ]
  end  

  return floorprint
end

#len: double
#width_1: double
#width_2: double
#end_1: double
#end_2: double
#off_1: double
#off_2: double
#off_3: double
#height: double
#number_of_floors: integer
#perim_and_core: boolean
def create_h_shape(len, width_1, width_2, end_1, end_2, off_1, off_2, off_3, height, number_of_floors, perim_and_core, perim_depth)
  floorprint = []
  
  if not perim_and_core  
    floorprint << ["ZN_1", height, 
     			[ 
     			  [0,   0],
    			  [end_1, 0],
    			  [end_1, off_2],
    			  [end_1, width_1 - off_1],
    			  [end_1, width_1],
    			  [0, width_1]
    			]
    		  ]
    		  
    floorprint << ["ZN_2", height,
     		   	[
     		   	  [end_1, off_2],
     		   	  [len - end_2, off_2],
     		   	  [len - end_2, width_1 - off_1],
     		   	  [end_1, width_1 - off_1]
     		   	]
     		  ]
    floorprint << ["ZN_3", height,
    			[
    			  [len - end_2, off_3],
    			  [len, off_3],
    			  [len, off_3 + width_2],
    			  [len - end_2, off_3 + width_2],
    			  [len - end_2, width_1 - off_1],
    			  [len - end_2, off_2]
    			]
    		  ]
    		  
  else
    floorprint << ["ZN_1", height, 
     			[ 
     			  [0,   0],
    			  [end_1, 0],
    			  [end_1 - perim_depth, perim_depth],
    			  [perim_depth, perim_depth]
    			]
    		  ]  

    floorprint << ["ZN_2", height, 
     			[ 
     			  [end_1 - perim_depth, perim_depth],
    			  [end_1, 0],
    			  [end_1, off_2],
    			  [end_1 - perim_depth, off_2 + perim_depth]
    			]
    		  ]  

    floorprint << ["ZN_3", height, 
     			[ 
     			  [end_1, off_2],
     			  [len - end_2, off_2],
     			  [len - end_2 + perim_depth, off_2 + perim_depth],
     			  [end_1 - perim_depth, off_2 + perim_depth]
     			]
    		  ]  

    floorprint << ["ZN_4", height, 
     			[ 
     			  [len - end_2, -off_3],
     			  [len - end_2 + perim_depth, -off_3 + perim_depth],
     			  [len - end_2 + perim_depth, off_2 + perim_depth],
     			  [len - end_2, off_2]
     			]
    		  ]  

    floorprint << ["ZN_5", height,
    			[
    			  [len - end_2, -off_3],
    			  [len, -off_3],
    			  [len - perim_depth, -off_3 + perim_depth],
    			  [len - end_2 + perim_depth, -off_3 + perim_depth]
    			]
    	           ]
    			  
    floorprint << ["ZN_6", height,
    			[
    			  [len - perim_depth, -off_3 + perim_depth],
    			  [len, -off_3],
    			  [len, -off_3 + width_2],
    			  [len - perim_depth, -off_3 + width_2 - perim_depth]
    			]
    	           ]
    		  
    floorprint << ["ZN_7", height,
    			[
    			  [len - end_2 + perim_depth, -off_3 + width_2 - perim_depth],
    			  [len - perim_depth, -off_3 + width_2 - perim_depth],
    			  [len, -off_3 + width_2],
    			  [len - end_2, -off_3 + width_2]
    			]
    	           ]    			  
    			
    floorprint << ["ZN_8", height,
    			[
    			  [len - end_2, width_1 - off_1],
    			  [len - end_2 + perim_depth, width_1 - off_1 - perim_depth],
    			  [len - end_2 + perim_depth, -off_3 + width_2 - perim_depth],
    			  [len - end_2, -off_3 + width_2]
    			]
    	           ]            
        
    floorprint << ["ZN_9", height,
    			[
    			  [end_1 - perim_depth, width_1 - off_1 - perim_depth],
    			  [len - end_2 + perim_depth, width_1 - off_1 - perim_depth],
    			  [len - end_2, width_1 - off_1],
    			  [end_1, width_1 - off_1]
    			]
    	           ]            
        
    floorprint << ["ZN_10", height,
    			[
    			  [end_1 - perim_depth, width_1 - off_1 - perim_depth],
    			  [end_1, width_1 - off_1],
    			  [end_1, width_1],
    			  [end_1 - perim_depth, width_1 - perim_depth]
    			]
    	           ]      
    	           
    	           
    floorprint << ["ZN_11", height,
    			[
    			  [perim_depth, width_1 - perim_depth],
    			  [end_1 - perim_depth, width_1 - perim_depth],
    			  [end_1, width_1],
    			  [0, width_1]
    			]
    	           ]      
 
    floorprint << ["ZN_12", height,
    			[
    			  [0, 0],
    			  [perim_depth, perim_depth],
    			  [perim_depth, width_1 - perim_depth],
    			  [0, width_1]
    			]
    	           ]      
        
    floorprint << ["ZN_13", height,
    			[
    			  [perim_depth, perim_depth],
    			  [end_1 - perim_depth, perim_depth],
    			  [end_1 - perim_depth, off_2 + perim_depth],
    			  [end_1 - perim_depth, width_1 - off_1 - perim_depth],
    			  [end_1 - perim_depth, width_1 - perim_depth],
    			  [perim_depth, width_1 - perim_depth]
    			]
    	           ]      

    floorprint << ["ZN_14", height,
    			[
    			  [end_1 - perim_depth, off_2 + perim_depth],
    			  [len - end_2 + perim_depth, off_2 + perim_depth],
    			  [len - end_2 + perim_depth, width_1 - off_1 - perim_depth],
    			  [end_1 - perim_depth, width_1 - off_1 - perim_depth]
    			]
    	           ]      

    floorprint << ["ZN_15", height,
    			[
    			  [len - end_2 + perim_depth, -off_3 + perim_depth],
    			  [len - perim_depth, -off_3 + perim_depth],
    			  [len - perim_depth, -off_3 + width_2 - perim_depth],
    			  [len - end_2 + perim_depth, -off_3 + width_2 - perim_depth],
    			  [len - end_2 + perim_depth, width_1 - off_1 - perim_depth],
    			  [len - end_2 + perim_depth, off_2 + perim_depth]
    			]
    	           ]      
        

  end  

  return floorprint
end

#flr_arr: array
def create_zoning(building, fp, floor_id, section_id)
  #this is a complete hack, but shows how to take the floorprint array and create the
  #zoning
  
  #zone = T_EP_Zone.Create;
  zone_name = "#{fp[0]}_FLR_#{floor_id}_SECTION_#{section_id}"
  puts zone_name
  
  zone = OpenStudio::Model::Zone.new(building)
  zone.setString(0, "#{zone_name}")
  #zone.OccupiedConditioned := true;
  zone.setXOrigin(fp[2][0][0])
  zone.setYOrigin(fp[2][0][1])
  zone.setZOrigin((floor_id - 1) * fp[1])
  #zone.CeilingHeight := T_EP_Point(aFootprint.EP_Points[0]).Z1;
  
  ind = 0
  puts "size of fp2: #{fp[2].size}"
  fp[2].each do |p_1|
    ind += 1
    
    if ind == 1 
      p_0 = fp[2][fp[2].size-1]
    else
      p_0 = fp[2][ind-1]
    end
    
    if ind == fp[2].size
      p_2 = fp[2][0]
    else
      p_2 = fp[2][ind]
    end
      
    puts "ind: #{ind}, p_0: #{p_0.inspect}, p_1: #{p_1.inspect}, p_2: #{p_2.inspect}"
    
    surf = OpenStudio::Model::Surface.new(building)
    surf.setZone(zone)  #why is it this way... shouldn't this be a method of zone (i.e. zone.addSurface(xyz))
    surf_name = "#{zone_name}_WALL_#{zone.surfaces.count}"
    surf.setString(0, "#{surf_name}")  #this is cheeezzy
    surf.setOutsideBoundaryCondition("Outdoors")
    surf.setSurfaceType("Wall")
    surf.setString(2, "AIR-WALL")
    verts = OpenStudio::Point3dVector.new
    verts << OpenStudio::Point3d.new(p_1[0] - zone.getXOrigin.get,
    				     p_1[1] - zone.getYOrigin.get,
    				     fp[1])
    verts << OpenStudio::Point3d.new(p_1[0] - zone.getXOrigin.get,
    				     p_1[1] - zone.getYOrigin.get,
    				     0.0)
    verts << OpenStudio::Point3d.new(p_2[0] - zone.getXOrigin.get,
    				     p_2[1] - zone.getYOrigin.get,
    				     0.0)
    verts << OpenStudio::Point3d.new(p_2[0] - zone.getXOrigin.get,
    				     p_2[1] - zone.getYOrigin.get,
    				     fp[1])

    verts = OpenStudio::reorderULC(verts)
    surf.setVertices(verts)
  end
  
  #add floor to core
  surf = OpenStudio::Model::Surface.new(building)
  surf.setZone(zone)  #why is it this way... shouldn't this be a method of zone (i.e. zone.addSurface(xyz))
  surf_name = "#{zone_name}_FLOOR"
  surf.setString(0, "#{surf_name}")  #this is cheeezzy
  surf.setOutsideBoundaryCondition("Outdoors")
  surf.setSurfaceType("Floor")
  surf.setString(2, "AIR-WALL")
  verts = OpenStudio::Point3dVector.new
  (fp[2].size-1).downto(0) do |ind|
    p_1 = fp[2][ind]
      
    if ind == 1 
      p_0 = fp[2][fp[2].size-1]
    else
      p_0 = fp[2][ind-1]
    end
      
    if ind == fp[2].size
      p_2 = fp[2][0]
    else
      p_2 = fp[2][ind]
    end
        
    puts "ind: #{ind}, p_0: #{p_0.inspect}, p_1: #{p_1.inspect}, p_2: #{p_2.inspect}"
    
    verts << OpenStudio::Point3d.new(p_1[0] - zone.getXOrigin.get,
        			     p_1[1] - zone.getYOrigin.get,
    				     0.0)
  end
  verts = OpenStudio::reorderULC(verts)
  surf.setVertices(verts)
  
  #add ceiling to core
  surf = OpenStudio::Model::Surface.new(building)
  surf.setZone(zone)  #why is it this way... shouldn't this be a method of zone (i.e. zone.addSurface(xyz))
  surf_name = "#{zone_name}_CEILING"
  surf.setString(0, "#{surf_name}")  #this is cheeezzy
  surf.setOutsideBoundaryCondition("Outdoors")
  surf.setSurfaceType("Ceiling")
  surf.setString(2, "AIR-WALL")  #this is cheeezzy too
  verts = OpenStudio::Point3dVector.new
  (0..fp[2].size-1).each do |ind|
    p_1 = fp[2][ind]
      
    if ind == 1 
      p_0 = fp[2][fp[2].size-1]
    else
      p_0 = fp[2][ind-1]
    end
      
    if ind == fp[2].size
      p_2 = fp[2][0]
    else
      p_2 = fp[2][ind]
    end
        
    puts "ind: #{ind}, p_0: #{p_0.inspect}, p_1: #{p_1.inspect}, p_2: #{p_2.inspect}"
    
    verts << OpenStudio::Point3d.new(p_1[0] - zone.getXOrigin.get,
        			     p_1[1] - zone.getYOrigin.get,
    				     fp[1])
  end      
  verts = OpenStudio::reorderULC(verts)
  surf.setVertices(verts) 
end



