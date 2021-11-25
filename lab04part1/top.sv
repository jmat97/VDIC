module top();
    shape shape_h;
	integer fd;
    string shape_name;
	real w, h;
	
    initial begin
        fd = $fopen("./lab04part1_shapes.txt", "r");
        if (!fd) $fatal(1, "Invalid file descritor");
        while (!$feof(fd)) begin
            void'($fscanf(fd, "%s %f %f", shape_name, w, h));     
            shape_factory::make_shape(shape_name, w, h);
 
        end
        
        shape_reporter#(rectangle)::report_shapes();
        shape_reporter#(square)::report_shapes();
        shape_reporter#(triangle)::report_shapes();
        
        $finish;
    end
    
endmodule