require 'spec_helper'
require 'heirloom/cli'

describe Heirloom do

  before do

    @catalog = { 'test1' =>
                   { 'regions'       => ['us-west-1', 'us-east-1'],
                     'bucket_prefix' => ['bp1'] },
                 'test2' => 
                   { 'regions'       => ['us-west-2'],
                     'bucket_prefix' => ['bp2'] }
               } 
    @formatter = Heirloom::CLI::Formatter::Catalog.new


  end

  context "unfiltered" do
    it "should return the formatted list" do

      @formatter.format(:region  => 'us-west-1',
                        :catalog => @catalog,
                        :details => nil,
                        :name    => nil ).should == [ "us-west-1","  test1\n  test2" ]
    end
  end

  context "filtered" do
    #it "should return the name with details" do
    #  format = "test1\n" +
    #           "  metadata_region  : us-west-1\n" +
    #           "  regions          : us-west-1, us-east-1\n" +
    #           "  bucket_prefix    : bp1\n" +
    #           "  us-west-1-s3-url : s3://bp1-us-west-1/test1\n" +
    #           "  us-east-1-s3-url : s3://bp1-us-east-1/test1"
    #  @formatter.should_receive(:name_exists?).and_return(true)
    #  f = @formatter.format(:region  => 'us-west-1',
    #                        :catalog => @catalog,
    #                        :name    => 'test1')
    #  f.should == format
    #
    #end

    it "should return false if name does not exist in catalog" do
      @formatter.format(:catalog => @catalog,
                        :name    => 'not_here').should == false
    end
  end

end
