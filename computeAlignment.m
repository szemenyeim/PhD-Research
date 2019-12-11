function Align = computeAlignment( Objects, PointCloudData, ModelData )

objNum = size( Objects, 1 );


for i=1:ObjNum
    
    Align( i ) = alignPC2Mesh( PointcloudData( i ), ModelData( Objects( i ).category ) );
    
end