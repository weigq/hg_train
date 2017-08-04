local conv = nnlib.SpatialConvolution
local batchnorm = nn.SpatialBatchNormalization
local relu = nnlib.ReLU

-- Main convolutional block
local function convBlock(numIn,numOut)
    return nn.Sequential()
        :add(batchnorm(numIn))
        :add(relu(true))
        :add(conv(numIn,numOut/2,1,1))
        :add(batchnorm(numOut/2))
        :add(relu(true))
        :add(conv(numOut/2,numOut/2,3,3,1,1,1,1))
        :add(batchnorm(numOut/2))
        :add(relu(true))
        :add(conv(numOut/2,numOut,1,1))
end

-- Skip layer
local function skipLayer(numIn,numOut)
    if numIn == numOut then
        return nn.Identity()
    else
        return nn.Sequential()
            :add(conv(numIn,numOut,1,1))
    end
end


-- HRbranch
local function HRbranch(numIn, numOut)
    return nn.Sequential()
        :add(batchnorm(numIn))
        :add(relu(true))
        :add(nn.SpatialMaxPooling(2,2,2,2))
        :add(conv(numIn,numOut,3,3,1,1,1,1))
        :add(batchnorm(numOut))
        :add(relu(true))
        :add(conv(numOut,numOut,3,3,1,1,1,1))
        :add(nn.SpatialUpSamplingNearest(2))
end

-- Residual block
function Residual(numIn,numOut)
    return nn.Sequential()
        :add(nn.ConcatTable()
            :add(convBlock(numIn,numOut))
            :add(skipLayer(numIn,numOut))
            :add(HRbranch(numIn,numOut)))
        :add(nn.CAddTable(true))
end

