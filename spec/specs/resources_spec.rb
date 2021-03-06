require 'spec_helper'

describe Gioco do
  let(:user) { FactoryGirl.create(:user) }
  let(:type) { Type.find_by_name "comments" }
  let(:noob_badge) { Badge.find_by_name "noob" }
  let(:medium_badge) { Badge.find_by_name "medium" }

  context "Get a new resource and add and remove points to it" do

    it "should have nil as value of points" do
      user.points.should == []
    end

    context "Incressing points to an user win noob badge of type comment" do

      it "Add the noob badge and the points related to an user" do
        user.change_points(points: noob_badge.points, type: type.id)
        user.reload
        user.badges.should include noob_badge
        user.points.where(:type_id => type.id).sum(:value) == noob_badge.points
      end

      it "Add points related to a user's type, using single increases" do
        final_score = 4
        final_score.times do
          user.change_points(points: 1, type: type.id)
        end
        user.points.where(:type_id => type.id).sum(:value).should == final_score
      end

      it "Remove points related to a user's type, using single decreases" do
        initial_score = 10
        final_score = 4
        user.change_points(points: initial_score, type: type.id)
        (initial_score - final_score).times do
          user.change_points(points: -1, type: type.id)
        end
        user.points.where(:type_id => type.id).sum(:value).should == final_score
      end
    end

    context "Decressing points to an user loose meidum badge" do

      before(:all) do
        user.change_points(points: medium_badge.points, type: type.id)
      end

      it "Remove the medium badge and the points related" do
        user.change_points(points: - medium_badge.points, type: type.id)
        user.reload
        user.badges.should_not include medium_badge
        user.points.where(:type_id => type.id).sum(:value) == 0
      end
    end
  end

  context "Getting resource data related with next badge" do

    it "should return a hash with the info for the noob_badge" do
      user.next_badge?(type.id).should == { :badge=> noob_badge,
                                            :points=> noob_badge.points,
                                            :percentage=> 0
                                          }
    end

    it "should return a hash with the info for the medium_badge" do
      noob_badge.add user.id
      user.next_badge?(type.id).should == { :badge=> medium_badge,
                                            :points=> medium_badge.points - user.points.sum(:value),
                                            :percentage=>(user.points.sum(:value) - user.badges.last.points)*100/(medium_badge.points - user.badges.last.points)
                                          }
    end
  end
end