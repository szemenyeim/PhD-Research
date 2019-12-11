function A = graphKernel( Nx, Ny, E1x, E1y, Exy, nodeFeatureNum )
Nxt = [ Nx( 1:nodeFeatureNum )'; E1x( 2 ); Exy( 2 ) ];
Nyt = [ Ny( 1:nodeFeatureNum )'; E1y( 2 ); Exy( 2 ) ];
A = tangentialEdgeKernel( Exy ) * ( centralEdgeKernel( E1x ) * Nxt ) * ( centralEdgeKernel( E1y ) * Nyt )';