require 'rails_helper'

describe Fractal do
  it 'is valid with name' do
    expect(Fractal.new name: 'Lsd25').to be_valid
  end
  it 'is valid without name' do
    expect(Fractal.new name: '').to be_valid
  end
  it "is valid when name is ascii" do
    expect(Fractal.new name: 'Lsd?$@').to be_valid
  end
  it "is invalid when name is not ascii" do
    fractal=Fractal.new name: 'ЛСд?$@'
    expect(fractal).to be_invalid
    expect(fractal.errors.has_key? :name).to eq true
  end
  # REC_NUMBER
  describe 'testing rec_number:' do
    it 'is invalid with nil rec_number' do
      expect(Fractal.new rec_number: nil).to be_invalid
    end
    it 'is valid when rec_number greater than 0' do
      expect(Fractal.new rec_number: 1).to be_valid
    end
    it 'is invalid when rec_number less than 0' do
      expect(Fractal.new rec_number: -1).to be_invalid
    end
    it 'is invalid when rec_number is 0' do
      expect(Fractal.new rec_number: 0).to be_invalid
    end
  end
  # PARENT
  describe 'testing parent:' do
    it 'is valid without parent_id' do
      expect(Fractal.new parent_id: nil).to be_valid
    end
    it 'is invalid with incorrect parent_id' do
      fractal = Fractal.new parent_id: 666
      expect(fractal).to be_invalid
      expect(fractal.errors.has_key? :parent).to eq true
    end
    it 'is valid with existent parent' do
      satana = Fractal.create name: "Satana"
      lucifer= Fractal.new parent: satana
      expect(lucifer).to be_valid
    end
    it 'has no parent after destroying parent' do
      jessus    = Fractal.create name: 'jes'
      glebparad = Fractal.create name: 'gleb', parent: jessus
      expect(glebparad.parent).to eq(jessus)
      jessus.destroy
      glebparad.reload
      expect(glebparad.parent).to be_nil
    end

    it "has parent's parent as parent after destroying parent" do
      god = Fractal.create name: 'god'
      jessus    = Fractal.create name: 'jes', parent: god
      glebparad = Fractal.create name: 'gleb', parent: jessus
      jessus.destroy
      glebparad.reload
      expect(glebparad.parent_id).to eq(god.id)
    end
    it "can't be parent himself" do
      god = Fractal.create name: 'god'
      god.parent = god
      expect(god).to be_invalid
      expect(god.errors.has_key? :parent).to eq true
    end
  end

  # SCOPES
  describe "scopes:" do
    before :each do
      @leo = User.create email: Faker::Internet.email
      @meo = User.create email: Faker::Internet.email
     
      @fractals=[]
      (0..20).each do |i|
        user = (i/3).odd? ? @leo : @meo
        name = i.odd? ? Faker::Name.name : nil
        @fractals<<IteratedFunctionSystem.create( user: user, name: name, score: i%7 )
      end
      @named= @fractals.select {|fr| fr.name.to_s != '' }
      @fresh= @fractals.sort {|a,b| b.created_at <=> a.created_at}

      @likest= @fractals.sort do |a,b| 
        if a.score == b.score
          a.id <=> b.id
        else
          b.score <=> a.score 
        end
      end
      @named_likest = @likest.select {|fr| not fr.name.to_s.empty?}
      @named_fresh = @fresh.select {|fr| not fr.name.to_s.empty?}
      @likest_fresh = @fractals.sort do |a,b|
        if a.score == b.score
          b.created_at <=> a.created_at
        else
          b.score <=> a.score
        end
      end
      @named_likest_fresh = @likest_fresh.select {|fr| not fr.name.to_s.empty?}
    end
    context "scope named" do
      it "returns valid array" do
        expect(Fractal.named).to eq(@named)
      end
    end
    context "scope fresh" do
      it "returns valid array" do
        expect(Fractal.fresh).to eq(@fresh)
      end
    end
    context "scope likest" do
      it "returns valid array" do
        expect(Fractal.likest).to eq(@likest)
      end
    end
    context "scope named.fresh" do
      it "returns valid array" do
        expect(Fractal.likest.fresh).to eq(@likest_fresh)
      end
    end
    context "scope named.likest.fresh" do
      it "returns valid array" do
        expect(Fractal.named.likest.fresh).to eq(@named_likest_fresh)
      end
    end
    context "Fractal.list" do
      it "without arguments returns scope named.likest.fresh" do
        expect(IteratedFunctionSystem.list).to eq(@named_likest_fresh)
      end
      it "when sort is :cools returns scope named.likest.fresh" do
        expect(IteratedFunctionSystem.list sort: :cools).to eq(@named_likest_fresh)
        expect(IteratedFunctionSystem.list sort: "cools").to eq(@named_likest_fresh)
      end
      it "when sort is :fresh returns scope named.fresh" do
        expect(IteratedFunctionSystem.list sort: :fresh).to eq(@named_fresh)
        expect(IteratedFunctionSystem.list sort: "fresh").to eq(@named_fresh)
      end
      it "when sort is invalid string or symbol" do
        expect(IteratedFunctionSystem.list sort: :aa).to eq(@named_likest_fresh)
        expect(IteratedFunctionSystem.list sort: "ools").to eq(@named_likest_fresh)
      end
      it "when only user_id is presented returns user's named.fresh" do
        expect(IteratedFunctionSystem.list me: @leo, user_id: @meo.id).to eq(@named_fresh.select {|fr| fr.user_id == @meo.id})
      end
      it "when me and user_id args are different returns user's named.fresh" do
        expect(IteratedFunctionSystem.list me: @leo, user_id: @meo.id).to eq(@named_fresh.select {|fr| fr.user_id == @meo.id})
        expect(IteratedFunctionSystem.list me: @leo, user_id: @meo.id.to_s).to eq(@named_fresh.select {|fr| fr.user_id == @meo.id})
      end
      it "when me and user_id args are same returns scope fresh" do
        expect(IteratedFunctionSystem.list me: @leo, user_id: @leo.id).to eq(@fresh.select {|fr| fr.user_id == @leo.id})
        
      end
    end
    %i[next prev].each do |m|
      context "method #{m}" do
        def method_args_sequence method, args, sequence
          fractals = method == :next ? [sequence.last] : [sequence.first]
          while fr=fractals.try(method == :next ? :first : :last)
            push_method = method == :next ? :unshift : :push
            fractals.try push_method, fr.try(method, args)
          end
          fractals-=[nil]
          expect(fractals).to eq(sequence)
        end
        it "works fine with no args" do
          method_args_sequence(m, {}, @named_likest_fresh)
        end
        it "works fine with {sort: :cools}" do
          method_args_sequence(m, {sort: :cools}, @named_likest_fresh)
          method_args_sequence(m, {sort: 'cools'}, @named_likest_fresh)
        end
        it "works fine with {sort: :fresh}" do
          method_args_sequence(m, {sort: :fresh}, @named_fresh)
          method_args_sequence(m, {sort: 'fresh'}, @named_fresh)
        end
        it "works fine with incorrect sort" do
          method_args_sequence(m, {sort: :ools}, @named_likest_fresh)
          method_args_sequence(m, {sort: 'ools'}, @named_likest_fresh)
        end
        it "works fine with valid user_id" do
          method_args_sequence(m, {user_id: @leo.id}, @named_fresh.select {|fr| fr.user_id == @leo.id})
          method_args_sequence(m, {user_id: @meo.id}, @named_fresh.select {|fr| fr.user_id == @meo.id})
        end
      end
    end
  end
end
