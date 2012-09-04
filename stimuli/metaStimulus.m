% ========================================================================
%> @brief metaStimulus light wrapper for opticka stimuli
%> METASTIMULUS a collection of stimuli, wrapped in one structure
% ========================================================================
classdef metaStimulus < optickaCore
	
	%--------------------PUBLIC PROPERTIES----------%
	properties 
		%>cell array of stimuli to manage
		stimuli = {}
		%> screenManager handle
		screen
		%> verbose?
		verbose = true
		%> choose only 1 stimulus
		choice = []
	end
	
	%--------------------DEPENDENT PROPERTIES----------%
	properties (SetAccess = private, Dependent = true) 
		%> n number of stimuli managed by metaStimulus
		n
	end
	
	%--------------------VISIBLE PROPERTIES----------%
	properties (SetAccess = private, GetAccess = public) 
		%> stimulus family
		family = 'meta'
		%> for heterogenous stimuli, we need a way to index into the stimulus so
		%> we don't waste time doing this on each iteration
		sList
	end
	
	%--------------------PRIVATE PROPERTIES----------%
	properties (SetAccess = private, GetAccess = private) 
		%> allowed properties passed to object upon construction
		allowedProperties = 'verbose|stimuli|screen|family'
		
	end
	
	%=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================
		
		% ===================================================================
		%> @brief Class constructor
		%>
		%> More detailed description of what the constructor does.
		%>
		%> @param args are passed as a structure of properties which is
		%> parsed.
		%> @return instance of class.
		% ===================================================================
		function obj = metaStimulus(varargin)
			if nargin == 0; varargin.name = 'metaStimulus';end
			%obj=obj@optickaCore(varargin); %superclass constructor
			if nargin>0; obj.parseArgs(varargin,obj.allowedProperties); end
		end
		
		% ===================================================================
		%> @brief setup wrapper
		%>
		%> @param
		%> @return
		% ===================================================================
		function setup(obj,choice)
			for i = 1:obj.n
				setup(obj.stimuli{i},obj.screen);
			end
		end
		
		% ===================================================================
		%> @brief update wrapper
		%>
		%> @param
		%> @return
		% ===================================================================
		function update(obj,choice)
			if exist('choice','var') %user forces a single stimulus
				
				update(obj.stimuli{choice});
				
			elseif ~isempty(obj.choice) %object forces a single stimulus
				
				update(obj.stimuli{obj.choice});
				
			else
		
				for i = 1:obj.n
					update(obj.stimuli{i});
				end
				
			end
		end
		
		% ===================================================================
		%> @brief draw wrapper
		%>
		%> @param
		%> @return
		% ===================================================================
		function draw(obj,choice)
			if exist('choice','var') %user forces a single stimulus
				
				draw(obj.stimuli{choice});
				
			elseif ~isempty(obj.choice) %object forces a single stimulus
				
				draw(obj.stimuli{obj.choice});
				
			else
				
				for i = 1:obj.n
					draw(obj.stimuli{i});
				end
				
			end
		end
		
		% ===================================================================
		%> @brief animate wrapper
		%>
		%> @param
		%> @return
		% ===================================================================
		function animate(obj,choice)
			if exist('choice','var') %user forces a single stimulus
				
				animate(obj.stimuli{choice});
				
			elseif ~isempty(obj.choice) %object forces a single stimulus
				
				animate(obj.stimuli{obj.choice});
				
			else
				
				for i = 1:obj.n
					animate(obj.stimuli{i});
				end
				
			end
		end
		
		% ===================================================================
		%> @brief reset wrapper
		%>
		%> @param
		%> @return
		% ===================================================================
		function reset(obj,choice)

			for i = 1:obj.n
				reset(obj.stimuli{i});
			end
			
		end
		
		% ===================================================================
		%> @brief set stimuli sanity checker
		%> @param
		%> @return 
		% ===================================================================
		function set.stimuli(obj,in)
			if iscell(in)
				obj.stimuli = [];
				obj.stimuli = in;
			elseif isa(in,'baseStimulus') %we are a single opticka stimulus
				obj.stimuli = {in};
			elseif isempty(in)
				obj.stimuli = {[]};
			else
				error([obj.name ':set stimuli | not a cell array or baseStimulus child']);
			end
		end
		
		
		% ===================================================================
		%> @brief get n dependent methos
		%> @param
		%> @return n number of stimuli
		% ===================================================================
		function n = get.n(obj)
			n = length(obj.stimuli);
		end
		
		% ===================================================================
		%> @brief subsref allow {} to call stimuli cell array
		%>
		%> @param  s is the subsref struct
		%> @return out any output
		% ===================================================================
		function varargout = subsref(obj,s)
			switch s(1).type
				% Use the built-in subsref for dot notation
				case '.'
					[varargout{1:nargout}] = builtin('subsref',obj,s);
				case '()'
					%error([obj.name ':subsref'],'Not a supported subscripted reference')
					[varargout{1:nargout}] = builtin('subsref',obj.stimuli,s);
				case '{}'
					[varargout{1:nargout}] = builtin('subsref',obj.stimuli,s);
			end
		end
		
		% ===================================================================
		%> @brief subsref allow {} to call stimuli cell array
		%>
		%> @param  s is the subsref struct
		%> @return out any output
		% ===================================================================
		function obj = subsasgn(obj,s,val)
			switch s(1).type
				% Use the built-in subsref for dot notation
				case '.'
					obj = builtin('subsasgn',obj,s,val);
				case '()'
					%error([obj.name ':subsasgn'],'Not a supported subscripted reference')
					sout = builtin('subsasgn',obj.stimuli,s,val);
					if ~isempty(sout)
						obj.stimuli = sout;
					else
						obj.stimuli = {};
					end
				case '{}'
					sout = builtin('subsasgn',obj.stimuli,s,val);
					if ~isempty(sout)
						if max(size(sout)) == 1
							sout = sout{1};
						end
						obj.stimuli = sout;
					else
						obj.stimuli = {};
					end
			end
		end
		
		% ===================================================================
		%> @brief updatesList
		%> Updates the list of stimuli current in the object
		%> @param
		% ===================================================================
		function updatesList(obj)
			obj.sList.n = 0;
			obj.sList.list = [];
			obj.sList.index = [];
			obj.sList.gN = 0;
			obj.sList.bN = 0;
			obj.sList.dN = 0;
			obj.sList.sN = 0;
			obj.sList.uN = 0;
			if ~isempty(obj.stimuli)
				obj.sList.n=obj.n;
				for i=1:obj.n
					obj.sList.index = [obj.sList.index i];
					switch obj.stimuli{i}.family
						case 'grating'
							obj.sList.list = [obj.sList.list 'g'];
							obj.sList.gN = obj.sList.gN + 1;
						case 'bar'
							obj.sList.list = [obj.sList.list 'b'];
							obj.sList.bN = obj.sList.bN + 1;
						case 'dots'
							obj.sList.list = [obj.sList.list 'd'];
							obj.sList.dN = obj.sList.dN + 1;
						case 'spot'
							obj.sList.list = [obj.sList.list 's'];
							obj.sList.sN = obj.sList.sN + 1;
						otherwise
							obj.sList.list = [obj.sList.list 'u'];
							obj.sList.uN = obj.sList.uN + 1;
					end
				end
			end
		end
		
		
		
	end
	
	%=======================================================================
	methods ( Access = protected ) %-------PRIVATE (protected) METHODS-----%
	%=======================================================================
		
	end
end