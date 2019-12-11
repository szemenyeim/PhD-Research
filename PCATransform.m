function T = PCATransform( A, V, numOfComponents )

Tt = A * V;
T = Tt( : , 1:numOfComponents ); 