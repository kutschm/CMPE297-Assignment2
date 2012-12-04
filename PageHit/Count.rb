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
    
  d = Mongo::Connection.new.db('pagehit')
  c = d['page_hits']
  
p = c.group({
                   :keyf => "function(doc) {								
                             return { ip: doc.ip,
									  day: doc.created_at.getDate(),
									  hour: doc.created_at.getHours(),
                                      min: doc.created_at.getMinutes() }; }",
                   :reduce => "function( curr, result ) { 
                              result.count1++;                              
                              }",
                   :initial => { :count1 => 0
                               }
              });

  stringVal = "";                              
  p.each { |row| 
     stringVal += row.to_json + "<br>" };
     
  stringVal;                             
end
