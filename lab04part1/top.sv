module top();
    shape shape_h;
    rectangle rectangle_h;
    square square_h;
    triangle triangle_h;
	
	integer fd;
    string shape;
	real w, h;
	
    initial begin
        fd = $fopen("./lab04part1_shapes.txt", "r");
        if (!fd) $fatal(1, "Invalid file descritor");
        while (!$feof(fd)) begin
            void'($fscanf(fd, "%s %f %f", shape, w, h));
                  
            shape_h = shape_factory::make_shape(shape, w, h);
            
            if ($cast(rectangle_h, shape_h)) begin
	                shape_reporter#(rectangle)::store_shape(rectangle_h);
	            end
            else if ($cast(square_h, shape_h)) begin
	                shape_reporter#(square)::store_shape(square_h);
	            end
            else if ($cast(triangle_h, shape_h)) begin
	                shape_reporter#(triangle)::store_shape(triangle_h);
	            end
            else $fatal (1, {"No such shape: ", shape});
 
        end
        
        shape_reporter#(rectangle)::report_shapes();
        shape_reporter#(square)::report_shapes();
        shape_reporter#(triangle)::report_shapes();
        
        $finish;
    end
    
endmodule