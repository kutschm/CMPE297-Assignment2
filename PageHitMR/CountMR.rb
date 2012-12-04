require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongo_mapper'


MongoMapper.database = 'pagehit';

class PageHit
  include MongoMapper::Document  
  key :ip, String
  timestamps!
end



get '/' do  
  
  curTime = Time.new;
  pagehit = PageHit.new(:ip => request.ip);
  pagehit.save;
  
  d = Mongo::Connection.new.db('pagehit');
  c = d['page_hits'];

mapFn = "function() {
      emit( { ip: this.ip,
              day: this.created_at.getDate(),
		      hour: this.created_at.getHours(),
		      min: this.created_at.getMinutes() },
		    { count: 1} );
}";
  
reduceFn = "function(key, values) {
	  var count = 0;
	  values.forEach(function(val) { 
	     count += val['count'];
	  });
	  
	  return {count: count};
  }";  
  
  c.mapreduce(mapFn, reduceFn, { out: "countMR"});
              
  stringVal = "";                
                
  d["countMR"].find.each { |row| 
     stringVal += row.to_json + "<br>" };
     
  stringVal;
end
