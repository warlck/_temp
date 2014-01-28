require 'spec_helper'

describe PointExpirer do
	 let(:pe) { PointExpirer.new }
	 subject{ pe }

	 it	{ should respond_to(:expire)}
end

