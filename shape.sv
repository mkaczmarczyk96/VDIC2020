
virtual class shape;
	protected real width = 0;
	protected real height = 0;

	function new(real w, real h);
		width  = w;
		height = h;
	endfunction : new

	pure virtual function real get_area();
	pure virtual function void print();

endclass : shape


class square extends shape;

	function new(real w, real h);
		super.new(w,w);
	endfunction : new

	function real get_area();
		return super.width*super.width;
	endfunction

	function void print();
		$display("Square w=%g area=%g",super.width,get_area());
	endfunction
	
endclass : square

class rectangle extends shape;

	function new(real w, real h);
		super.new(w,h);
	endfunction : new

	function real get_area();
		return super.width*super.height;
	endfunction

	function void print();
		$display("Rectangle w=%g h=%g area=%g",super.width,super.height,get_area());
	endfunction

endclass :rectangle


class triangle extends shape;

	function new(real w, real h);
		super.new(w,h);
	endfunction : new

	function real get_area();
		return (super.width*super.height)/2;
	endfunction

	function void print();
		$display("Triangle w=%g h=%g area=%g",super.width,super.height,get_area());
	endfunction

endclass : triangle

class shape_factory;

	static function shape make_shape(string shape_type,real width, real height);

		square square_m_s;
		rectangle rectangle_m_s;
		triangle triangle_m_s;
		
		case (shape_type)
			"square" : begin
				square_m_s    = new(width, height);
				return square_m_s;
			end
			
			"rectangle" : begin
				rectangle_m_s = new(width, height);
				return rectangle_m_s;
			end			

			"triangle" : begin
				triangle_m_s  = new(width, height);
				return triangle_m_s;
			end

		endcase 
	endfunction : make_shape
endclass : shape_factory

class shape_reporter #(type T=shape);

	protected static T shape_storage [$];

	static function void store_shape(T shape);
		shape_storage.push_back(shape);
	endfunction : store_shape

	static function void report_shapes();
		static real area_sum=0.0;
		foreach (shape_storage[i]) begin
			area_sum += shape_storage[i].get_area();
			shape_storage[i].print();
		end
		$display("Total Area: %g\n",area_sum);
	endfunction
	
	

endclass : shape_reporter


module top;

	initial begin
		shape shape_t;
		square square_t;
		rectangle rectangle_t;
		triangle triangle_t;

		int file_handle;
		int c;
		
		string shape_type;
		real width,height;

		bit cast_rectangle;
		bit cast_square;
		bit cast_triangle;

		

		file_handle = $fopen("lab02part2A_shapes.txt", "r");

		while (!$feof(file_handle)) begin
			c = $fscanf(file_handle,"%s %g %g",shape_type,width,height);
			if(c==3)begin
				shape_t = shape_factory::make_shape(shape_type, width, height);

				cast_square    = $cast(square_t, shape_t);
				cast_rectangle = $cast(rectangle_t, shape_t);
				cast_triangle  = $cast(triangle_t, shape_t);

				case({cast_square,cast_rectangle,cast_triangle})
					3'b100: shape_reporter#(square)::store_shape(square_t);
					3'b010: shape_reporter#(rectangle)::store_shape(rectangle_t);
					3'b001: shape_reporter#(triangle)::store_shape(triangle_t);
				endcase
			end
		end
		shape_reporter#(square)::report_shapes();
		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
	end

endmodule : top
