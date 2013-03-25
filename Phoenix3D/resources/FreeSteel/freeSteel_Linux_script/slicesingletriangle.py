import freesteelpy as kernel

fssurf = kernel.FsSurf.New()
fssurf.PushTriangle(0,0,0, 0,2,0, 0.4,0.1,1)
fssurf.Build(1.0)

fshoriztoolsurf = kernel.FsHorizontalToolSurface.New()
fshoriztoolsurf.AddSurf(fssurf)
fshoriztoolsurf.AddTipShape(0.4, 0.3, 0.5)   # (corner_radius, flat_radius, z)

fsimplicitarea = kernel.FsImplicitArea.New(0)
fsimplicitarea.AddHorizToolSurf(fshoriztoolsurf)
fsimplicitarea.SetContourConditions(0.99, -1.0, 0.002, 2, -1.0, 0.9)

fsweave = kernel.FsWeave.New()
fsweave.SetShape(-5, 5, -5, 5, 0.17) # (xlo, xhi, ylo, yhi, approx_resolution)
fsimplicitarea.GenWeaveZProfile(fsweave)
ncontours = fsweave.GetNContours()
print fsweave.StructureContours()
for inum in range(ncontours):
    fspath = kernel.FsPath2X.New(0.0)
    print fspath.RecordContour(fsweave, False, inum, 0.002)

    # G-code style output
    npts = fspath.GetNpts()
    print "\n".join([ "G1X%.2fY%.2f"  % (fspath.GetD(i, 0), fspath.GetD(i, 1))  for i in range(npts) ])
